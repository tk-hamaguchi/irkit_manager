# language: ja

機能: Gemパッケージのビルド

シナリオ: rakeコマンドでgemパッケージをビルドできる
  もし `rake build`を実行する
  ならば 標準出力に出力された内容が/^irkit_manager \d+\.\d+\.\d+ built to pkg\/irkit_manager-\d+\.\d+\.\d+\.gem.$/にマッチする
  かつ ビルドされたGemファイルが"pkg"配下に存在している
