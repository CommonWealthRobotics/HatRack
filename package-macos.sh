#https://cdn.azul.com/zulu/bin/zulu17.50.19-ca-fx-jdk17.0.11-macosx_x64.tar.gz
NAME=BowlerLauncher
VERSION=1.0.1
MAIN=com.commonwealthrobotics.HatRackMain

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ARCH=x86_64
JVM=zulu17.50.19-ca-fx-jdk17.0.11-macosx_x64
if [[ $(uname -m) == 'arm64' ]]; then
  ARCH=arm46
  echo "M1 Mac detected https://cdn.azul.com/zulu/bin/zulu17.50.19-ca-fx-jdk17.0.11-macosx_aarch64.tar.gz" 
  JVM=zulu17.50.19-ca-fx-jdk17.0.11-macosx_aarch64
else
  echo "x86 Mac detected https://cdn.azul.com/zulu/bin/zulu17.50.19-ca-fx-jdk17.0.11-macosx_x64.tar.gz" 

fi
set -e
ZIP=$JVM.tar.gz
export JAVA_HOME=$HOME/bin/java17/
if test -d $JAVA_HOME/$JVM/; then
  echo "$JAVA_HOME exists."
else
	rm -rf $JAVA_HOME
	mkdir -p $JAVA_HOME
	curl https://cdn.azul.com/zulu/bin/$ZIP -o $ZIP
	tar -xvzf $ZIP -C $JAVA_HOME
	mv $JAVA_HOME/$JVM/* $JAVA_HOME/
fi

./gradlew jar


ICON=$NAME.png
cp BowlerStudioIcon.png $ICON
rm -rf $SCRIPT_DIR/$NAME
rm -rf $SCRIPT_DIR/$NAME.AppDir
BUILDDIR=lib/build/libs/ 
TARGETJAR=lib.jar
rm -rf *.dmg
echo "Building DMG..."
MACIMAGE=MacIconSourceImage.png
mkdir $NAME.iconset
sips -z 16 16     $MACIMAGE --out $NAME.iconset/icon_16x16.png
sips -z 32 32     $MACIMAGE --out $NAME.iconset/icon_16x16@2x.png
sips -z 32 32     $MACIMAGE --out $NAME.iconset/icon_32x32.png
sips -z 64 64     $MACIMAGE --out $NAME.iconset/icon_32x32@2x.png
sips -z 128 128   $MACIMAGE --out $NAME.iconset/icon_128x128.png
sips -z 256 256   $MACIMAGE --out $NAME.iconset/icon_128x128@2x.png
sips -z 256 256   $MACIMAGE --out $NAME.iconset/icon_256x256.png
sips -z 512 512   $MACIMAGE --out $NAME.iconset/icon_256x256@2x.png
sips -z 512 512   $MACIMAGE --out $NAME.iconset/icon_512x512.png
cp $MACIMAGE $NAME.iconset/icon_512x512@2x.png
iconutil -c icns $NAME.iconset
rm -R $NAME.iconset

$JAVA_HOME/bin/jpackage --input $BUILDDIR \
  --name $NAME \
  --main-jar $TARGETJAR \
  --main-class $MAIN \
  --type dmg \
  --copyright "Creative Commons" \
  --vendor "Common Wealth Robotics" \
  --icon $NAME.icns \
  --app-version "$VERSION" \
  --java-options '--enable-preview'
ls -al
rm -rf release
mkdir release
mv $NAME-$VERSION.dmg release/$NAME-$ARCH.dmg