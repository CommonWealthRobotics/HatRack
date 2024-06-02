./gradlew jar

VERSION=0.0.1


NAME=BowlerStudioUpdater
ICON=BowlerStudioIcon.png
rm -rf $NAME
rm -rf *.AppDir

~/bin/java17/bin/jpackage --input lib/build/libs/ \
  --name $NAME \
  --main-jar lib.jar \
  --main-class com.commonwealthrobotics.HatRackMain \
  --type app-image \
  --app-version $VERSION \
  --java-options '--enable-preview'
 
mkdir -p $NAME.AppDir/usr/bin
cp -r $NAME/* $NAME.AppDir/usr/bin/

mkdir -p  $NAME.AppDir/usr/share/applications
mkdir -p  $NAME.AppDir/usr/share/icons/hicolor/256x256/apps

cat << EOF > $NAME.AppDir/usr/share/applications/$NAME.desktop
[Desktop Entry]
Name=MyApp
Exec=$NAME
Icon=$ICON
Type=Application
Categories=Utility;
EOF
 
cp $ICON $NAME.AppDir/usr/share/icons/hicolor/256x256/apps/$NAME.png
 
# Step 2: Install AppImageTool (done once)
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage

./appimagetool-x86_64.AppImage BowlerStudioUpdater.AppDir
