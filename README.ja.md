SendEventLog.ps1
================
Windowsイベントログをメールで送信します。
メッセージの内容あるいはProviderNameとIdでフィルタリングできます。
Windows8.1で使えなくなった[NotifyEventLog](http://www.forest.impress.co.jp/library/software/notifevent/)の代わりになることを目指しています。

* 対象OS: Windows Vista以降
 - Vista以前では [NotifyEventLog](http://www.forest.impress.co.jp/library/software/notifevent/)が利用可能です。

セットアップ
================
* PowerShellスクリプトの実行を有効にする
 - ここを参照してください。 http://www.atmarkit.co.jp/fwin2k/win2ktips/1023ps1sec/ps1sec.html
* インストールする
 - 適当な場所にすべてのファイルを置いてください。
* 設定する
 - SendEventLog.ps1をテキストエディタで開き、メール等の設定を行ってください。
* タスクスケジューラーに登録する
 - タスクスケジューラーを開き、タスクを新規作成します。
 - トリガーに「スタートアップ時」、「繰り返し間隔：1時間」を設定します。
   - デフォルトでは60分前までのログをメールする設定になっているため
 - 操作に「プログラムの開始」、「プログラム/スクリプト：powershell.exe」、「引数：SendEventLog.ps1のファイルパス」を設定します。
* テスト実行する
 - SendEventLog.ps1をダブルクリックすると、指定した設定でイベントログがメールで送信されます。
 - ダブルクリックして動作しない場合、何らかの設定に問題があります。
