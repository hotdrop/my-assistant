# assistant_me
OpenAI APIを利用したアシスタントWebアプリです。  
公式のChatGPTUIが個人的に使いづらく自分用にカスタマイズしたかったのが作成動機です。  

本アプリは`Firebase Hosting`にデプロイする想定で作っています。  
`flutterfire`を使っていますので`main.dart`の`DefaultFirebaseOptions`は`flutterfire configure`で自動生成されます。  

また、APIKeyは永続領域には持たず、メモリに保持しているのでページをリロードしたり開き直すと再度設定が必要となります。  

# コマンド
```
// ビルド 自分用なのでweb-rendererは指定しません
flutter build web

// デプロイ
firebase deploy
```

# スクショ
<img src="./images/02_history.png" width=300>
<img src="./images/03_graph.png" width=300>

# TODO
## 優先度高
1. 会話用のテンプレート機能
2. 今後のモデルのためにsystemを会話を開始する際に設定する機能つける。設定は会話用テンプレと同じ枠に
3. 履歴のタイトル編集（今は会話の先頭30文字。テンプレート機能と同時に欲しい）
4. 履歴の文字列検索機能

## 優先度低
1. Stream対応
   1. →今のところあまり不便ではないので後回し
