   L-os Angeles Gaku (Tablacus/Lovers)  
   Ok  
   ;         [A:LA      .SYS	X1版　L-os Angeles](https://github.com/tablacus/LosAngeles/releases)  
   ;         [A:LA      .   	LAの外部コマンド](https://github.com/tablacus/LosAngeles/tree/main/LA)  
   ;         [A:LADOC   .   	LAの解説](https://github.com/tablacus/LosAngeles/tree/main/LADOC)  
   ;         [A:BINDOC  .   	LAの外部コマンドの解説](https://github.com/tablacus/LosAngeles/tree/main/BINDOC)  
   ;         [A:LASYS   .   	LAのソースリスト](https://github.com/tablacus/LosAngeles/tree/main/LASYS)  
   ;         [A:BINS    .   	LAの外部コマンドのソースリスト](https://github.com/tablacus/LosAngeles/tree/main/BINS)  
   ;         [A:LAIPL   .   	IPLのソースリスト](https://github.com/tablacus/LosAngeles/tree/main/LAIPL)  
   ;         A:COMMAND .BAT	LAの自動実行ファイル  
   ;         A:LA      .COM	X1・C-DOSII等からLAを起動させるコマンド  
   ;         [A:LAE     .COM	MSX-DOS版　L-os Angeles](https://github.com/tablacus/LosAngeles/releases)  


# プログラム名	

- L-os Angeles
1. LA.SYS(X1版)
2. LAE,COM(MSX-DOS版)


# 対応環境

1. X1シリーズ&X1turbo/Zシリーズ
2. MSX-DOS


# はじめに

- 現在ではエミュレータで仮想ディスクを使いますし、各種フォーマットコンバーターもそろっています。
- MS-DOSフォーマットであるという利点はもうすでに無いと思います。
- また、S-OS "SWORD"はS-OSのディスクフォーマットへの依存度が高いため、別のディスクフォーマットであるMS-DOSフォーマットでは一度に読み込めない大きなファイルを扱うソフトや複数のファイルを同時に開くようなソフトはそのままでは動きません。
- 今ではL-os Angelesはただの互換性が低いS-OSでしかないと思っています。
- ちなみに、Angelsではなくsの前にeが付きます。


# 機能概略

- MS-DOS互換のファイルフォーマットとS-OS互換のサブルーチン&ワークエリア+αを持つOS
- 階層ディレクトリ・ワイルドカードに対応。
- turbo版はフロッピーの2D・2HDを自動判別します。
- 外部プログラムでいろいろと拡張出来ます。


# ライセンス

- MIT Licenseのフリーソフトウェアです。
		


# 管理等

- 以下の表に含まれていない新しいRAMディスク等のブロックデバイスのデバイスドライバを作られて配布される場合はご連絡いただけると幸いです。

| デバイス | DPB_DEVNO |
| ---- | ---- |
|G-RAM | 5 |
|EMM | 6 |
|フロッピー	| 7	($87)|
|B-RAM | 11 |
|特殊ワークエリア | 12 |
|ユーザー | 127 |
		下位7ビット有効



# X1版の諸注意

- シークエラーが出るとその後のステップレートを20msに落とし
ますが、高速のステップレートのドライブでは騒音と寿命に有利な
のでステップレートを最高速の設定にしている為にCZ-800F
では支障がある可能性があります。
- CZ-502F等のCZ-800F以降のドライブやX1本体に内蔵
されているドライブでは問題ありません
- LAは起動時にグラフィックをクリアしません。そのため特殊ワーク
エリアを利用しているS-OSのプログラムが若干おかしい事があり
ます。これはグラフィックをクリアしないS-OSでも同じ現象が出
ます。そういうソフトを用いる場合は"J 0A8F"等としてグラフィック
をクリアしましょう。最初に読み込まれる"COMMAND.BAT"に"J 0A8F"
の1行を入れておくと便利です。

