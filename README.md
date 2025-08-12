# @CameraTransform_K

![GitHub License](https://img.shields.io/github/license/korarei/AviUtl2_CameraTransform_K_Script)
![GitHub Last commit](https://img.shields.io/github/last-commit/korarei/AviUtl2_CameraTransform_K_Script)
![GitHub Downloads](https://img.shields.io/github/downloads/korarei/AviUtl2_CameraTransform_K_Script/total)
![GitHub Release](https://img.shields.io/github/v/release/korarei/AviUtl2_CameraTransform_K_Script)

AviUtl ExEdit2のカメラ操作感を変更するスクリプト群．

現在使用可能なスクリプト

- Transform

- Parent

- Track

[ダウンロードはこちらから．](https://github.com/korarei/AviUtl2_CameraTransform_K_Script/releases)

## 動作確認

- [AviUtl ExEdit2 beta6](https://spring-fragrance.mints.ne.jp/aviutl/)


## 導入・削除・更新

初期配置場所は`カメラ効果`である．

`オブジェクト追加メニューの設定`から`ラベル`を変更することで任意の場所へ移動可能．

### 導入

1.  同梱の`*.cam2`と`*.dll`を`%ProgramData%`内の`aviutl2\\Script`フォルダまたはその子フォルダに入れる．

`beta4`以降では`aviutl2.exe`と同じ階層内の`data\\Script`フォルダ内でも可．

### 削除

1.  導入したものを削除する．

### 更新

1.  導入したものを上書きする．

## 使い方
### Transform

3DCGソフトのようなカメラ操作感を提供するスクリプト．カメラ上方向ベクトルと方向ベクトルを指定方法で移動回転する．

- X, Y, Z: カメラの位置を定める．このとき，カメラの姿勢は変化しない．

- Rotation: `Rotation Mode`リストで選択した回転方法に従ってカメラの姿勢を変化させる．

- Rotation Mode: 回転方法を選択する．AviUtl標準の回転方法は`ZYX Euler`である．選択できる方法は以下の8通り．

  - Quaternion: W，X，Y，Z回転を使用する．Wが実部，X，Y，Zが虚部である．W，X，Y，Zは大きさが1になるように正規化される．

  - Axis Angle: W，X，Y，Z回転を使用する．Wが回転角度，X，Y，Zが回転軸である．

  - Euler: X，Y，Z回転を使用する．外因性オイラー角 (Tait–Bryan角である6種類) を指定．

- Parent Layer: 親オブジェクトのレイヤー番号を指定する．`0`または`カメラ自身のレイヤー番号`を指定した場合，下記`Parent`が存在すればそのデータを使用する．

親オブジェクトの位置，回転，拡大率によってカメラの座標系を移動させる．

- Use Relative Layer: `Parent Layer`で指定するレイヤー番号を相対値にする．

- PI: パラメータインジェクション．

```lua
{
  x = 0.0, -- カメラのX座標 (number)
  y = 0.0, -- カメラのY座標 (number)
  z = 0.0, -- カメラのZ座標 (number)
  rw = 0.0, -- カメラのW回転 (number)
  rx = 0.0, -- カメラのX回転 (number)
  ry = 0.0, -- カメラのY回転 (number)
  rz = 0.0, -- カメラのZ回転 (number)
  rot_mode = 21, -- カメラの回転モード (number)
  parent_layer = 0, -- 親オブジェクトのレイヤー (number)
  use_rel_layer = false -- 親オブジェクトのレイヤーを相対値で設定するかどうか (boolean or number)
}
```

`{}`は既に挿入済みであるため，PI項目では中身のみ記載する．

`rot_mode`は以下のように記載する．

- `0`: クォータニオン

- `1`: 軸回転

- `[5, 21]`: オイラー角 (外因性，Tait–Bryan角)

オイラー角の回転順序は`0(3)`をX軸，`1(3)`をY軸，`2(3)`をZ軸のように3進数で表現した軸を回転順に並べ，10進数に変換して表現する．

例えば，`XYZ Euler`は`012(3)`となり，`5`と表現する．

### Parent

`Transform`の`Parent Layer`が`0`または`カメラ自身のレイヤー番号`のとき，子どもとする`Transform`の1つ上に設置することで親オブジェクトとして使用できる．

通常オブジェクトとは異なり，回転方法としてZYXオイラー角以外を指定できる．

- X, Y, Z: 根本位置．

- Rotation: `Rotation Mode`リストで選択した回転方法に従って根本姿勢を変化させる．

- Rotation Mode: 回転方法を選択する．AviUtl標準の回転方法は`ZYX Euler`である．選択できる方法は以下の8通り．

  - Quaternion: W，X，Y，Z回転を使用する．Wが実部，X，Y，Zが虚部である．W，X，Y，Zは大きさが1になるように正規化される．

  - Axis Angle: W，X，Y，Z回転を使用する．Wが回転角度，X，Y，Zが回転軸である．

  - Euler: X，Y，Z回転を使用する．外因性オイラー角 (Tait–Bryan角である6種類) を指定．

- Zoom: 根本拡大率．

- PI: パラメータインジェクション．

```lua
{
  x = 0.0, -- 根本のX座標 (number)
  y = 0.0, -- 根本のY座標 (number)
  z = 0.0, -- 根本のZ座標 (number)
  rw = 0.0, -- 根本のW回転 (number)
  rx = 0.0, -- 根本のX回転 (number)
  ry = 0.0, -- 根本のY回転 (number)
  rz = 0.0, -- 根本のZ回転 (number)
  rot_mode = 21, -- 根本の回転モード (number)
  zoom = 100.0 -- 根本拡大率 (number)
}
```

`{}`は既に挿入済みであるため，PI項目では中身のみ記載する．

`rot_mode`は以下のように記載する．(`Transform`と同じ)

- `0`: クォータニオン

- `1`: 軸回転

- `[5, 21]`: オイラー角 (外因性, Tait–Bryan角)

オイラー角の回転順序は`0(3)`をX軸，`1(3)`をY軸，`2(3)`をZ軸のように3進数で表現した軸を回転順に並べ，10進数に変換して表現する．

例えば，`XYZ Euler`は`012(3)`となり，`5`と表現する．

### Track

目標オブジェクトに対してカメラを向けるスクリプト．

- Target Layer: 目標オブジェクトのレイヤー．

- Use Relative Layer: `Target Layer`で指定するレイヤー番号を相対値にする．

- Influence: 影響度．

- PI: パラメータインジェクション．

```lua
{
  target_layer = 1, -- 目標オブジェクトのレイヤー (number)
  use_rel_layer = false, -- 目標オブジェクトのレイヤーを相対値で設定するかどうか (boolean or number)
  influence = 100.0 -- 影響度 (number)
}
```

`{}`は既に挿入済みであるため，PI項目では中身のみ記載する．

## License

LICENSEファイルに記載．

## Change Log

- **v1.0.1**
  - 改行コードをCRLFに変更．

- **v1.0.0**
  - Release
