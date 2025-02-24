# Simplified OS

![image](https://github.com/user-attachments/assets/4c7ccd5a-40f1-41cc-bd1a-8ba65cfae592)

## 起動方法

このリポジトリをローカルにクローンして、`make`でビルドして実行します。
```bash
git clone https://github.com/KajizukaTaichi/SimplifiedOS.git
cd ./SimplifiedOS
make
```
ビルドには以下のツールが必要になります。

- **make**:<br>
  ビルド作業を自動化するツールです。
  先ほどのコードの3行目で`make`するのに使います
- **nasm**: <br>
  アセンブラです。
  ソースコード[`boot.asm`](./boot.asm) から機械語のバイナリを出力するのに使います。
- **qemu**:<br>
  実機がなくても仮想的に実行できるエミュレータです。
  `nasm`が吐いたバイナリを実行するのに使います。

これらは事前にインストールしてある必要があります。
ない場合は実行する前にインストールしてください。
