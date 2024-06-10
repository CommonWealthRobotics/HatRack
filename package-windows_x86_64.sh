echo "Windows bundling"
#https://cdn.azul.com/zulu/bin/zulu17.50.19-ca-fx-jdk17.0.11-win_x64.zip
JVM=zulu17.50.19-ca-fx-jdk17.0.11-win_x64
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ZIP=$JVM.zip
export JAVA_HOME=$HOME/bin/java17/


./gradlew jar
echo "Test jar in: $SCRIPT_DIR"
DIR=$SCRIPT_DIR/lib/build/libs/
INPUT_DIR="$SCRIPT_DIR/input"
JAR_NAME=lib.jar
$JAVA_HOME/bin/java.exe -jar $DIR/$JAR_NAME
echo "Test jar complete"
NAME=BowlerLauncher
ICON=BowlerStudioIcon.png

VERSION=0.0.1
PACKAGE=$JAVA_HOME/bin/jpackage.exe
mkdir -p "$INPUT_DIR"
cp "$DIR/$JAR_NAME" "$INPUT_DIR/"

$PACKAGE --input "$INPUT_DIR/" \
  --name "$NAME" \
  --main-jar "$JAR_NAME" \
  --main-class "com.commonwealthrobotics.HatRackMain" \
  --type "exe" \
  --temp "temp" --verbose --win-console \
  --app-version "$VERSION" \
  --icon "$ICON" \
  --java-options '--enable-preview'