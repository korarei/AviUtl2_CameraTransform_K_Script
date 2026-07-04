# CameraTransform_K

![GitHub License](https://img.shields.io/github/license/korarei/AviUtl2_CameraTransform_K_Script)
![GitHub Last commit](https://img.shields.io/github/last-commit/korarei/AviUtl2_CameraTransform_K_Script)
![GitHub Downloads](https://img.shields.io/github/downloads/korarei/AviUtl2_CameraTransform_K_Script/total)
[![GitHub Release][releases-badge]][releases-url]
[![AviUtl2 Catalog][catalog-badge]][catalog-url]

AviUtl ExEdit2 向けカメラ調整用ツール．

以下の機能が追加される．

カメラ効果

- カメラ効果\\Transform@CameraTransform_K: カメラの位置や向きを調整
- カメラ効果\\Track@CameraTransform_K: ターゲットへカメラを追従
- カメラ効果\\Lens@CameraTransform_K: 見え方そのものを調整

アニメーション効果

- 配置\\Empty@CameraTransform_K: エフェクト版グループ制御
- 配置\\Relations@CameraTransform_K: 他オブジェクトと同期

## 動作確認

- [AviUtl ExEdit2 beta53](https://spring-fragrance.mints.ne.jp/aviutl/)

> [!CAUTION]
> beta53 以降必須．

## 導入・更新・削除

### パッケージファイルからインストール

#### 導入・更新

[こちら][releases-url]からダウンロードした `*.au2pkg.zip` をAviUtl2にD&D．

#### 削除

パッケージ情報からアンインストールする．

### [AviUtl2 カタログ](https://github.com/Neosku/aviutl2-catalog)からインストール

[こちら][catalog-url]から導入，更新，削除を行う．

## 使い方

> [!TIP]
> エフェクトによるオブジェクトの座標変化を取得するためには `Parent Layer` や `Targrt Layer` で指定するオブジェクトに `Empty@CameraTransform_K` を追加する必要がある．

> [!WARNING]
> 親オブジェクトとグループ制御の組み合わせによっては意図通りの座標変換が行われない場合がある．

### Transform@CameraTransform_K

初期ラベル: `カメラ効果`

座標変換処理 (移動・回転・拡縮等) を行うスクリプト．

同一オブジェクトに複数配置した場合，下から上へ座標変換される．

#### パラメータ

- <details>
  <summary>Position</summary>

  - Position::X / Y / Z: 位置の変位を指定

  </details>

- <details>
  <summary>Rotation</summary>

  - Rotation::W / X / Y / Z: 回転の変位を指定
  - Rotation::Mode: 回転モードを指定 (Quaternion, Axis Angle, 外因性 Euler (Tait–Bryan) 各種)

  </details>

- <details>
  <summary>Scale</summary>

  - Scale::X / Y / Z: 拡大縮小の変位を指定

  </details>

- <details>
  <summary>Relations</summary>

  - Relations::Parent Layer: 親オブジェクトのレイヤー番号を指定

  </details>

- <details>
  <summary>Additional Options</summary>

  - Influence: 影響度合いを指定
  - Layer Reference: レイヤー指定の参照方法を指定
    - Absolute: 絶対指定 (指定したレイヤー番号)
    - Relative: 相対指定 (自身のレイヤーからの相対番号)

  </details>

### Track@CameraTransform_K

初期ラベル: `カメラ効果`

目標オブジェクトに対してカメラを向けるスクリプト．

#### パラメータ

- Target Layer: 目標オブジェクトのレイヤーを指定
- Track Axis: カメラを向ける軸を指定
  - X / -X: X軸
  - Y / -Y: Y軸
  - Z / -Z: Z軸

- <details>
  <summary>Additional Options</summary>

  - Influence: 影響度合いを指定
  - Layer Reference: レイヤー指定の参照方法を指定
    - Absolute: 絶対指定 (指定したレイヤー番号)
    - Relative: 相対指定 (自身のレイヤーからの相対番号)

  </details>

### Lens@CameraTransform_K

初期ラベル: `カメラ効果`

カメラの描画結果を調整するスクリプト．(実際のカメラレンズを再現するものではない．)

#### パラメータ

- Focal Length: 焦点距離を指定
- Dolly Zoom: 対象の大きさを変えずに焦点距離を変更するかどうか

- <details>
  <summary>Sensor</summary>

  - Sensor::Fit: 計算に用いる方向を指定
  - Sensor::Size: センササイズを指定

  </details>

- <details>
  <summary>Depth of Field</summary>

  - DOF::Focus Distance: 目標までの距離
  - DOF::Aperture::F-Stop: カメラの F 値

  </details>

### Empty@CameraTransform_K

初期ラベル: `配置`

親オブジェクトとして機能する．

> [!WARNING]
> エフェクトの個別オブジェクト設定が有効な場合は使用不可．

#### パラメータ

- <details>
  <summary>Position</summary>

  - Position::X / Y / Z: 位置の変位を指定

  </details>

- <details>
  <summary>Rotation</summary>

  - Rotation::W / X / Y / Z: 回転の変位を指定
  - Rotation::Mode: 回転モードを指定 (Quaternion, Axis Angle, 外因性 Euler (Tait–Bryan) 各種)

  </details>

- <details>
  <summary>Scale</summary>

  - Scale::X / Y / Z: 拡大縮小の変位を指定

  </details>

- <details>
  <summary>Relations</summary>

  - Relations::Parent Layer: 親オブジェクトのレイヤー番号を指定

  </details>

- <details>
  <summary>Visibility</summary>

  - Visibility::Show In::Viewports: プレビューで描画する
  - Visibility::Show In::Renders: レンダリングで描画する

  </details>

- <details>
  <summary>Additional Options</summary>

  - Influence: 影響度合いを指定
  - Layer Reference: レイヤー指定の参照方法を指定
    - Absolute: 絶対指定 (指定したレイヤー番号)
    - Relative: 相対指定 (自身のレイヤーからの相対番号)

  </details>

### Relations@CameraTransform_K

初期ラベル: `配置`

指定したオブジェクトの位置姿勢情報をコピーする．

- Parent Layer: 親オブジェクトのレイヤー番号を指定

- <details>
  <summary>Additional Options</summary>

  - Influence: 影響度合いを指定
  - Layer Reference: レイヤー指定の参照方法を指定
    - Absolute: 絶対指定 (指定したレイヤー番号)
    - Relative: 相対指定 (自身のレイヤーからの相対番号)

  </details>

## ビルド方法

[リリース用ワークフロー](./.github/workflows/releaser.yml)を参照されたい．

[extern](./modules/extern/) 内 `vcpkg` ディレクトリに [vcpkg](https://github.com/microsoft/vcpkg) 本体を配置する必要がある．

## ライセンス

本プログラムのライセンスは [LICENSE](./LICENSE) を参照されたい．

また，本プログラムが利用するサードパーティ製ライブラリ等のライセンス情報は [THIRD_PARTY_LICENSES](./THIRD_PARTY_LICENSES.md) に記載している．

## 更新履歴

[CHANGELOG](./CHANGELOG.md) を参照されたい．

<!-- links -->

[releases-url]: https://github.com/korarei/AviUtl2_CameraTransform_K_Script/releases
[releases-badge]: https://img.shields.io/github/v/release/korarei/AviUtl2_CameraTransform_K_Script
[catalog-url]: https://aviutl2-catalog-badge.sevenc7c.workers.dev/package/korarei.CameraTransform_K
[catalog-badge]: https://aviutl2-catalog-badge.sevenc7c.workers.dev/badge/v/korarei.CameraTransform_K
