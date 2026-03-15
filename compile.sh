#!/bin/bash
# Compilation script for Dust2 Enhancement Plugin

echo "========================================="
echo "Dust2 Enhancement Plugin - Compiler"
echo "========================================="
echo ""

# Check if amxxpc exists
if ! command -v amxxpc &> /dev/null; then
    echo "ERROR: amxxpc compiler not found!"
    echo ""
    echo "Please install AMX Mod X or add amxxpc to your PATH."
    echo "Download from: https://www.amxmodx.org/downloads.php"
    echo ""
    exit 1
fi

# Check if source file exists
if [ ! -f "dust2_enhancement.sma" ]; then
    echo "ERROR: dust2_enhancement.sma not found!"
    echo "Please run this script from the directory containing the source file."
    echo ""
    exit 1
fi

echo "Compiling dust2_enhancement.sma..."
echo ""

# Compile the plugin
amxxpc dust2_enhancement.sma

# Check compilation result
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "SUCCESS! Plugin compiled successfully."
    echo "========================================="
    echo ""
    echo "Output file: dust2_enhancement.amxx"
    echo ""
    echo "Next steps:"
    echo "1. Copy dust2_enhancement.amxx to addons/amxmodx/plugins/"
    echo "2. Add 'dust2_enhancement.amxx' to plugins.ini"
    echo "3. Restart your server or change to de_dust2"
    echo ""
else
    echo ""
    echo "========================================="
    echo "ERROR: Compilation failed!"
    echo "========================================="
    echo ""
    echo "Please check the error messages above."
    echo "Common issues:"
    echo "- Missing include files (amxmodx.inc, amxmisc.inc, fun.inc)"
    echo "- Syntax errors in the source code"
    echo "- Incompatible compiler version"
    echo ""
    exit 1
fi
