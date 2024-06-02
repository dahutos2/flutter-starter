# プロジェクト直下から再帰的に .gitignore ファイルを探索
find . -name ".gitignore" | while read -r gitignore; do
    # .gitignore の存在を確認
    if [ ! -f "$gitignore" ]; then
        continue
    fi

    # .gitignore ファイルのディレクトリに移動
    dir=$(dirname "$gitignore")
    echo "処理中のディレクトリ: $dir"
    cd "$dir" || continue

    # .gitignore に記載されたパターンを取得
    patterns=$(grep -v '^#' .gitignore | grep -v '^$')
    exclude_patterns=$(echo "$patterns" | grep '^!' | sed 's/^!//')

    # 除外パターンに一致するかどうかをチェックする関数
    is_excluded() {
        local item="$1"
        for exclude_pattern in $exclude_patterns; do
            if [[ "$item" == *"$exclude_pattern"* ]]; then
                return 0
            fi
        done
        return 1
    }

    # 先にディレクトリを削除
    echo "$patterns" | grep -v '^!' | while read -r pattern; do
        # フォルダパターンの処理（例：myenv/ および node_modules）
        if [[ "$pattern" == */ || -d "$pattern" ]]; then
            find . -path "./.git" -prune -o -type d -path "./${pattern}" -print | while read -r dir; do
                if ! is_excluded "$dir" && [ -e "$dir" ] && [ "$dir" != "." ] && [ "$dir" != ".." ]; then
                    echo "フォルダ削除中: $dir"
                    rm -rf "$dir"
                fi
            done
        fi
    done

    # 次にファイルを削除
    echo "$patterns" | grep -v '^!' | while read -r pattern; do
        # ファイルパターンの処理
        if [[ "$pattern" != */ ]]; then
            find . -path "./.git" -prune -o -type f -name "$pattern" -print | while read -r file; do
                if ! is_excluded "$file" && [ -e "$file" ] && [ "$file" != "." ] && [ "$file" != ".." ]; then
                    echo "ファイル削除中: $file"
                    rm -rf "$file"
                fi
            done
        fi
    done

    # 元のディレクトリに戻る
    cd - > /dev/null || exit 1
done

echo "削除が完了しました"