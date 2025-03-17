#!/usr/bin/env bash
set -e

# Clear previous builds
scons -c

# Compile Godot for linuxbsd x86_64 with mono
scons platform=windows arch=x86_64 module_mono_enabled=yes precision=double

# Generate the .NET glue code
wine ./bin/godot.windows.editor.double.x86_64.mono.exe --headless --generate-mono-glue modules/mono/glue

# Define the NuGet source name
NUGET_SOURCE_NAME="GodotMonoVoxel"

# Check if GodotMonoVoxel NuGet source already exists
if dotnet nuget list source | grep -A 1 "[[:space:]]${NUGET_SOURCE_NAME}[[:space:]]\["; then
    echo "${NUGET_SOURCE_NAME} NuGet source found."
    # Extract the existing source path from the NuGet CLI output
    VOXEL_SOURCE_PATH=$(dotnet nuget list source | grep -A 1 "[[:space:]]${NUGET_SOURCE_NAME}[[:space:]]\[" | tail -n 1 | xargs)
    echo "Using existing source path: $VOXEL_SOURCE_PATH"
else
    echo "${NUGET_SOURCE_NAME} NuGet source not found. Creating in bin/${NUGET_SOURCE_NAME}..."
    VOXEL_SOURCE_PATH="bin/${NUGET_SOURCE_NAME}"
    mkdir -p "$VOXEL_SOURCE_PATH"
    ABSOLUTE_PATH="$(pwd)/${VOXEL_SOURCE_PATH}"
    dotnet nuget add source "$ABSOLUTE_PATH" --name ${NUGET_SOURCE_NAME}
fi

# Build the assemblies and push them to your local NuGet source
./modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin \
  --push-nupkgs-local "$VOXEL_SOURCE_PATH" \
  --precision=double

chmod +x bin/godot.windows.editor.double.x86_64.mono.exe
