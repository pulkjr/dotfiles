#!/bin/bash

# Define colors for better visibility
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${RED}${BOLD}⚠️  WARNING: CAPS LOCK REBINDING REQUIRED${NC}"
echo -e "Remap ${BOLD}Caps Lock to Escape${BOLD} must be done manually.\n"

echo "1. Open System Settings > Keyboard."
echo "2. Click 'Keyboard Shortcuts...' then 'Modifier Keys'."
echo "3. Change 'Caps Lock (⇪) Key' to 'Escape'."
echo "4. Click Done."

echo -e "\n${RED}Note: The Terminal method resets after a reboot unless set as a LaunchAgent.${NC}"
