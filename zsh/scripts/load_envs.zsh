#!/usr/bin/env zsh
# environment loader for zsh
# Loads env variables from ~/.config/envs/*
local base="${HOME}/.config/envs"
local sourced_any=0

for f in "${base}/common.zsh" "${base}/dev.zsh" "${base}/stage.zsh"; do
if [[ -f "$f" ]]; then
  source "$f"
  sourced_any=1
fi
done

# Ensure maps exist
typeset -p GP_ENV_VARS_COMMON >/dev/null 2>&1 || typeset -A GP_ENV_VARS_COMMON
typeset -p GP_ENV_VARS_DEV     >/dev/null 2>&1 || typeset -A GP_ENV_VARS_DEV
typeset -p GP_ENV_VARS_STAGE   >/dev/null 2>&1 || typeset -A GP_ENV_VARS_STAGE

# --- Helpers ---------------------------------------------------------

_lc() { echo "${1:l}"; }

_resolve_host() {
  local host="$1"
  [[ -z "$host" ]] && { echo "[DEBUG _resolve_host] no host provided"; return 1; }

  local out rc

  # 1) dig (preferred) — check output for non-empty answer
  if [[ -x "/usr/bin/dig" ]]; then
    echo "[DEBUG _resolve_host] trying: /usr/bin/dig +time=2 +tries=1 +short $host" >&2
    out="$(/usr/bin/dig +time=2 +tries=1 +short "$host" 2>&1)"; rc=$?
    echo "[DEBUG _resolve_host] dig rc=$rc out='${out%%$'\n'*}'" >&2
    # dig returns the answer lines on stdout; require at least one non-empty line
    if [[ -n "$out" ]]; then
      # basic sanity: ensure output contains something that looks like an IP or name
      if [[ "$out" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "$out" =~ [A-Za-z0-9._-]+ ]]; then
        return 0
      fi
    fi
  fi

  # 2) host — parse for "has address" or "has IPv6 address"
  if [[ -x "/usr/bin/host" ]]; then
    echo "[DEBUG _resolve_host] trying: /usr/bin/host -W 1 $host" >&2
    out="$(/usr/bin/host -W 1 "$host" 2>&1)"; rc=$?
    echo "[DEBUG _resolve_host] host rc=$rc out='${out%%$'\n'*}'" >&2
    if [[ "$out" =~ "has address" || "$out" =~ "has IPv6 address" || "$out" =~ "is an alias for" ]]; then
      return 0
    fi
  fi

  # 3) nslookup — parse for "Address:" lines after the answer section
  if [[ -x "/usr/bin/nslookup" ]]; then
    echo "[DEBUG _resolve_host] trying: /usr/bin/nslookup $host" >&2
    out="$(/usr/bin/nslookup "$host" 2>&1)"; rc=$?
    echo "[DEBUG _resolve_host] nslookup rc=$rc out='${out%%$'\n'*}'" >&2
    # look for "Name:" / "Address:" lines that indicate an answer
    if echo "$out" | awk 'BEGIN{found=0} /Name:/{found=1} /Address:/{ if(found) {print; exit 0}}' | grep -q . 2>/dev/null; then
      return 0
    fi
  fi

  # 4) fallback: ping (last resort)
  echo "[DEBUG _resolve_host] trying: ping -c 1 -W 1 $host" >&2
  if ping -c 1 -W 1 "$host" >/dev/null 2>&1; then
    echo "[DEBUG _resolve_host] ping succeeded for $host" >&2
    return 0
  else
    echo "[DEBUG _resolve_host] ping failed for $host" >&2
  fi

  return 1
}



# --- A) Check VPN connection via gpstatus ----------------------------

_gp_cli_connected() {
  command -v gpstatus >/dev/null 2>&1 || return 1
  local out; out="$(gpstatus 2>/dev/null || true)"
  echo "$out" | grep -qi 'VPN is CONNECTED'
}

# --- B) Determine env via DNS (dev/stage only) ----------------------

_gp_dns_env() {
    local ddev="$(_lc ${GP_ENV_VARS_DEV[DOMAIN]})"
    local sdev="${GP_ENV_VARS_DEV[SERVER]}"
    local dstage="$(_lc ${GP_ENV_VARS_STAGE[DOMAIN]})"
    local sstage="${GP_ENV_VARS_STAGE[SERVER]}"

    # Lowercase for comparison
    local ddevlc="$(_lc "$sdev.$ddev")"
    local dstagelc="$(_lc "$sstage.$dstage")"

    # 2) Fallback: try resolving server names. Try short name then FQDN (short + searchDomain)
    local try
    if [[ -n "$sdev" ]]; then
        for try in "$ddevlc" "$ddev"; do
            [[ -z "$try" ]] && continue
            if _resolve_host "$try"; then
                echo "[DEBUG] Server resolution succeeded for DEV ($try)" >&2
                echo "dev"; return 0
            else
                echo "[DEBUG] Server resolution failed for DEV ($try)" >&2
            fi
        done
    fi

    for try in "${dstagelc}" "$dstage"; do
        [[ -z "$try" ]] && continue
        if _resolve_host "$try"; then
            echo "[DEBUG] Server resolution succeeded for STAGE ($try)" >&2
            echo "stage"; return 0
        else
            echo "[DEBUG] Server resolution failed for STAGE ($try)" >&2
        fi
    done

    echo "[DEBUG] No environment detected" >&2
    return 1
}


# --- Orchestrator ----------------------------------------------------

gp_detect_env() {
  echo "[DEBUG] Starting gp_detect_env..." >&2

  if ! _gp_cli_connected; then
    echo "[DEBUG] VPN is NOT connected (gpstatus check failed)" >&2
    echo "" >&2
    return 0
  fi

  echo "[DEBUG] VPN is connected (gpstatus check passed)" >&2

  local env=""
  env="$(_gp_dns_env)" || true

  if [[ -n "$env" ]]; then
    echo "[DEBUG] Environment detected: $env" >&2
    echo "$env"
  else
    echo "[DEBUG] No environment matched via DNS" >&2
    echo ""
  fi

  echo "[DEBUG] gp_detect_env finished" >&2
  return 0
}

gp_apply_env() {
    local env="${1//$'\r'/}"
    env="${env##+([[:space:]])}"
    env="${env%%+([[:space:]])}"
    [[ -z "$env" ]] && { echo "[ERROR] No environment specified"; return 1; }

    typeset -A src

    # Merge arrays safely
    if [[ -v GP_ENV_VARS_COMMON ]]; then
        src+=("${(@kv)GP_ENV_VARS_COMMON}")
    else
        echo "[WARN] GP_ENV_VARS_COMMON is not defined or empty" >&2
    fi

    case "$env" in
        dev)
            if [[ -v GP_ENV_VARS_DEV ]]; then
                src+=("${(@kv)GP_ENV_VARS_DEV}")
            else
                echo "[ERROR] GP_ENV_VARS_DEV is missing" >&2
                return 1
            fi
            ;;
        stage)
            if [[ -v GP_ENV_VARS_STAGE ]]; then
                src+=("${(@kv)GP_ENV_VARS_STAGE}")
            else
                echo "[ERROR] GP_ENV_VARS_STAGE is missing" >&2
                return 1
            fi
            ;;
        *)
            print -P "%F{red}[ERROR]%f Unknown environment: $env"
            return 1
            ;;
    esac

    for k v in "${(@kv)src}"; do
        echo "[DEBUG] Exporting $k" >&2
        export "$k=$v"
    done

    export GP_ACTIVE_ENV="$env"
    return 0
}

gp_env_init() {
  local env
  env="$(gp_detect_env)"

  if [[ -n "$env" ]] && gp_apply_env "$env"; then
    print -P "%F{green}[GP]%f VPN connected. Env applied: %F{yellow}$env%f"
    return 0
  fi

  return 1
}

gp_env_init || print -P "%F{red}[GP]%f Not connected"

