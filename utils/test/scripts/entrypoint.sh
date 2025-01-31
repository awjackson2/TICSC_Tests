#!/bin/bash

# Source FreeSurfer setup script if available
if [ -f $FREESURFER_HOME/SetUpFreeSurfer.sh ]; then
  source $FREESURFER_HOME/SetUpFreeSurfer.sh
fi

# Source FSL setup script if available
if [ -f $FSLDIR/etc/fslconf/fsl.sh ]; then
  source $FSLDIR/etc/fslconf/fsl.sh
fi

# Add FSL and FreeSurfer sourcing to .bashrc
echo "source \$FSLDIR/etc/fslconf/fsl.sh" >>~/.bashrc
echo "source \$FREESURFER_HOME/SetUpFreeSurfer.sh" >>~/.bashrc

# Ensure XDG_RUNTIME_DIR exists for GUI applications
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

exec "$@"
#!/bin/bash

# Source FreeSurfer setup script if available
if [ -f $FREESURFER_HOME/SetUpFreeSurfer.sh ]; then
  source $FREESURFER_HOME/SetUpFreeSurfer.sh
fi

# Source FSL setup script if available
if [ -f $FSLDIR/etc/fslconf/fsl.sh ]; then
  source $FSLDIR/etc/fslconf/fsl.sh
fi

# Add FSL and FreeSurfer sourcing to .bashrc
echo "source \$FSLDIR/etc/fslconf/fsl.sh" >>~/.bashrc
echo "source \$FREESURFER_HOME/SetUpFreeSurfer.sh" >>~/.bashrc

# Ensure XDG_RUNTIME_DIR exists for GUI applications
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

exec "$@"
