./gradlew jar

VERSION=0.0.1
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

NAME=BowlerLauncher
ICON=$NAME.png
rm -rf $SCRIPT_DIR/$NAME
rm -rf $SCRIPT_DIR/$NAME.AppDir

~/bin/java17/bin/jpackage --input lib/build/libs/ \
  --name $NAME \
  --main-jar lib.jar \
  --main-class com.commonwealthrobotics.HatRackMain \
  --type app-image \
  --app-version $VERSION \
  --java-options '--enable-preview'
 
mkdir -p $SCRIPT_DIR/$NAME.AppDir/usr/
cp -r $SCRIPT_DIR/$NAME/* $SCRIPT_DIR/$NAME.AppDir/usr/

mkdir -p  $NAME.AppDir/usr/share/applications
mkdir -p  $NAME.AppDir/usr/share/icons/hicolor/256x256/apps

cat << EOF > $NAME.AppDir/usr/share/applications/$NAME.desktop
[Desktop Entry]
Name=$NAME
Exec=BowlerStudioUpdater-$ARCH.AppImage
Icon=$NAME
Type=Application
Categories=Utility
EOF

cp $NAME.AppDir/usr/share/applications/$NAME.desktop $NAME.AppDir/$NAME.desktop
 
chmod 644 $SCRIPT_DIR/$NAME.AppDir/usr/share/applications/$NAME.desktop

ln -s usr/bin/$NAME  $SCRIPT_DIR/$NAME.AppDir/AppRun
ls -l $SCRIPT_DIR/$NAME.AppDir/AppRun

chmod 755 $SCRIPT_DIR/$NAME.AppDir/usr/bin/$NAME
chmod 755 $SCRIPT_DIR/$NAME.AppDir/AppRun

cp $ICON $NAME.AppDir/usr/share/icons/hicolor/256x256/apps/$NAME.png
cp $ICON $NAME.AppDir/$NAME.png

# Step 2: Install AppImageTool (done once)
TOOL=appimagetool-x86_64.AppImage
if test -f $TOOL; then
	echo $TOOL exists
else
	wget https://github.com/AppImage/AppImageKit/releases/download/continuous/$TOOL
	chmod +x $TOOL
fi
tree $NAME.AppDir
export ARCH=x86_64
./$TOOL $NAME.AppDir
