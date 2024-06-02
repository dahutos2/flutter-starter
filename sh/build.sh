# OS選択肢
echo "Select the target OS:"
echo "1) Android"
echo "2) iOS"
echo "3) macOS"
echo "4) Windows"
echo "5) Linux"
echo "6) Web"
read -p "Enter the number of the target OS: " os_choice

case $os_choice in
    1)
        os="apk"
        ;;
    2)
        os="ios"
        ;;
    3)
        os="macos"
        ;;
    4)
        os="windows"
        ;;
    5)
        os="linux"
        ;;
    6)
        os="web"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# ビルドモード選択肢
echo "Select the build mode:"
echo "1) Debug"
echo "2) Profile"
echo "3) Release"
read -p "Enter the number of the build mode: " mode_choice

case $mode_choice in
    1)
        mode="debug"
        ;;
    2)
        mode="profile"
        ;;
    3)
        mode="release"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# ビルドコマンドの実行
echo "Building for $os in $mode mode..."
flutter build $os --$mode

# ビルド結果の確認
if [ $? -eq 0 ]; then
    echo "Build successful."
else
    echo "Build failed."
fi
