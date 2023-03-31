# assistant_me
OpenAI APIを利用したアシスタントWebアプリです。  
公式のChatGPTUIが個人的に使いづらく自分用にカスタマイズしたかったのが作成動機です。  

本アプリは`Firebase Hosting`にデプロイする想定で作っています。  
そのままでは`main.dart`がビルドエラーになりますが、`flutterfire configure`で`DefaultFirebaseOptions`を生成すれば解消されます。  
また、RiverpodやHiveでGeneratorを使っているのでbuild_runnerを動かしてください。

APIKeyは永続領域には持たず、メモリに保持しているのでページをリロードしたり開き直すと再度設定が必要となります。  

# コマンド
```
// ビルド 自分用なのでweb-rendererは指定しません
flutter build web

// デプロイ
firebase deploy
```

# スクショ
<img src="./images/01_home.png" width=300><img src="./images/02_history.png" width=300>
<img src="./images/03_graph.png" width=300><img src="./images/04_template.png" width=300>
