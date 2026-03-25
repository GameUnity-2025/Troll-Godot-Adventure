# iOS Export + TestFlight Checklist

## 1. Soat preset iOS hien tai trong repo

Preset iOS da ton tai trong `export_presets.cfg`, nhung cac truong quan trong de export va day len TestFlight hien con de trong.

### Cac truong dang trong va ban bat buoc phai dien

- `application/app_store_team_id`
- `application/bundle_identifier`
- `application/short_version`
- `application/version`

### Cac truong nen kiem tra va dien neu can

- `application/code_sign_identity_debug`
- `application/code_sign_identity_release`
- `application/provisioning_profile_specifier_debug`
- `application/provisioning_profile_specifier_release`
- `application/export_method_release`
- `application/export_method_debug`
- `application/min_ios_version`
- `application/targeted_device_family`

### Privacy va tracking trong preset hien tai

- `privacy/tracking_enabled=false`
- Toan bo `privacy/collected_data/*` dang la `false`

Neu ban dua AdMob vao ban iOS that, phan privacy nay can duoc doi cho khop cach app thu thap va su dung du lieu. Khong nen de sai voi App Store Connect.

### Icon iOS hien tai

Tat ca icon iOS dang de trong. Ban can dien it nhat bo icon day du, dac biet:

- `icons/app_store_1024x1024`
- `icons/iphone_120x120`
- `icons/iphone_180x180`
- `icons/ipad_152x152`
- `icons/ipad_167x167`

Neu chi muon len TestFlight noi bo som, van nen dien icon day du ngay tu dau de tranh loi validation trong Xcode hoac App Store Connect.

## 2. Checklist cac o can dien trong Godot

Mo `Project > Export > iOS` va dien theo thu tu nay:

### Application

- `App Store Team ID`: ma 10 ky tu trong Apple Developer, vi du `ABCDE12XYZ`
- `Bundle Identifier`: vi du `com.tencongty.trollgodotadventure`
- `Short Version`: vi du `1.0.0`
- `Version`: vi du `1`
- `Min iOS Version`: giu `14.0` neu ban khong co ly do gi de ha xuong
- `Targeted Device Family`: chon dung thiet bi muon ho tro

### Signing

Neu ban de Xcode tu signing, co the tam de trong mot so truong trong Godot va hoan tat trong Xcode. Tuy vay, `Team ID` va `Bundle Identifier` van phai co.

### Icons

- Dien du icon iPhone/iPad/App Store
- App Store icon phai la anh vuong 1024x1024, khong alpha

### Privacy

- Neu khong dung tracking: giu `tracking_enabled=false`
- Neu dung AdMob co personalized ads hoac IDFA: can xem lai `tracking_enabled` va ATT truoc khi phat hanh
- Neu app co thu thap du lieu lien quan ads, can cap nhat `privacy/collected_data/*`

### Additional plist content

Neu plugin AdMob iOS khong tu chen day du, ban se phai them vao day cac key trong `Info.plist`, it nhat:

- `GADApplicationIdentifier`
- `SKAdNetworkItems`

## 3. Soat AdMob hien tai trong repo

### Nhung gi repo dang co

- Plugin la Poing Studios AdMob `v3.1.3`
- Plugin da duoc enable trong project
- Android export dang bat plugin AdMob
- Android manifest dang de `APPLICATION_ID` mau cua Google

### Nhung gi repo chua co cho iOS

Hai thu muc native download cua plugin dang trong, chi co `.gitkeep`:

- `addons/admob/downloads/android/`
- `addons/admob/downloads/ios/`

Dieu nay co nghia la repo hien tai chua kem goi native iOS cua plugin. Neu khong tai va cai phan nay, ban co the export duoc Xcode project nhung build iOS co kha nang loi hoac AdMob khong hoat dong.

### Nhung gi ban can them de iOS build duoc voi AdMob

1. Tai native iOS package cua plugin Poing AdMob trong Godot editor.
2. Cai dat package iOS theo huong dan cua plugin vao Xcode project export ra.
3. Them `GADApplicationIdentifier` vao `Info.plist` cua iOS build.
4. Them `SKAdNetworkItems` vao `Info.plist`.
5. Tao app iOS rieng trong AdMob va lay:
   - App ID iOS
   - Ad Unit ID banner iOS
   - Ad Unit ID interstitial iOS
   - Ad Unit ID rewarded iOS
6. Khai bao privacy trong App Store Connect phu hop voi AdMob.

### Lam cac buoc tren trong Godot nhu the nao

#### Buoc 1 - Tai native iOS package cua plugin ngay trong Godot

Lam trong Godot duoc.

1. Mo project trong Godot.
2. Tren thanh menu editor, tim menu `AdMob Download Manager`.
3. Chon `AdMob Download Manager > iOS > LatestVersion`.
4. Cho plugin tai file zip iOS ve thu muc `addons/admob/downloads/ios/`.
5. Neu can kiem tra file da tai xong chua, chon `AdMob Download Manager > iOS > Folder`.
6. Neu can xem huong dan goc cua plugin, chon `AdMob Download Manager > iOS > GitHub`.

Luu y: repo hien tai chua co native iOS package san, nen buoc nay la buoc dau tien ban phai lam neu muon build iOS co AdMob.

#### Buoc 2 - Cai package iOS vao Xcode project export ra

Khong lam xong hoan toan trong Godot duoc.

Godot chi giup ban tai package va export project Xcode. Phan cai native iOS framework vao project build that la viec cua Xcode hoac script cai dat di kem plugin.

Cach lam:

1. Trong Godot, vao `AdMob Download Manager > iOS > Copy shell command`.
2. Plugin se copy lenh cai dat vao clipboard.
3. Export iOS project tu Godot ra mot thu muc rieng.
4. Mo Terminal tai thu muc chua package iOS cua plugin hoac thu muc huong dan cua plugin.
5. Chay lenh duoc copy de plugin chen cac framework va file can thiet vao project Xcode vua export.

Noi ngan gon: buoc nay bat dau tu Godot, nhung thao tac cai dat that su xay ra ngoai Godot.

#### Buoc 3 - Them `GADApplicationIdentifier`

Co the chuan bi tu Godot, nhung can kiem tra lai trong Xcode.

Cach lam trong Godot:

1. Vao `Project > Export > iOS`.
2. Tim truong `application/additional_plist_content`.
3. Dan them noi dung plist bo sung, vi du:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

4. Export lai project iOS.
5. Sau khi export, mo Xcode va kiem tra file `Info.plist` cua target xem key nay da co mat chua.

Neu plugin iOS cua ban tu chen key nay thi khong can dan tay, nhung lan dau nen kiem tra bang mat trong Xcode.

#### Buoc 4 - Them `SKAdNetworkItems`

Co the them bang Godot, nhung thuc te van nen verify trong Xcode.

Cach lam trong Godot:

1. Vao `Project > Export > iOS`.
2. O truong `application/additional_plist_content`, dan them phan `SKAdNetworkItems`.
3. Danh sach ID nay phai lay tu tai lieu AdMob iOS moi nhat hoac tai lieu plugin neu plugin co cap nhat san.
4. Export lai project.
5. Mo `Info.plist` trong Xcode de kiem tra no da duoc merge dung chua.

Luu y: danh sach `SKAdNetworkItems` thuong dai va co the thay doi theo thoi gian, nen khong nen hard-code mot danh sach cu ma khong doi chieu voi tai lieu moi nhat.

#### Buoc 5 - Tao app iOS rieng trong AdMob va lay App ID / Ad Unit ID

Khong lam trong Godot duoc.

Buoc nay ban phai lam tren dashboard AdMob:

1. Tao app iOS trong AdMob.
2. Lay `App ID` iOS.
3. Tao tung `Ad Unit ID` rieng cho banner, interstitial, rewarded.
4. Quay lai Godot va thay cac test id trong script bang iOS ad unit id that cua ban.

Noi ban se thay trong repo:

- `CommonScripts/ads/Interstatial.gd`
- `CommonScripts/ads/Rewarded.gd`

Luu y: Android va iOS khong dung chung App ID hoac Ad Unit ID.

#### Buoc 6 - Khai bao privacy trong App Store Connect

Khong lam trong Godot duoc hoan toan.

Trong Godot, ban chi chuan bi du lieu de khai dung hon:

1. Vao `Project > Export > iOS`.
2. Xem lai `privacy/tracking_enabled`.
3. Xem lai cac truong `privacy/collected_data/*`.
4. Neu app co ads that, dung de tat ca o muc `false` neu thuc te app co thu thap du lieu quang cao.

Nhung phan khai chinh thuc voi Apple van phai lam trong App Store Connect khi ban nap build.

#### Tom tat nhanh: cai gi lam duoc trong Godot

- Tai native iOS package cua plugin
- Mo duong dan thu muc package iOS
- Copy lenh cai dat plugin iOS
- Dien `additional_plist_content`
- Dien privacy fields trong preset iOS
- Thay ad unit id trong script game

#### Tom tat nhanh: cai gi khong lam xong trong Godot

- Tao app iOS trong AdMob
- Tao App ID iOS va ad unit iOS
- Cai framework vao build release that neu plugin can buoc Xcode/script rieng
- Verify signing va embedded frameworks
- Khai App Privacy chinh thuc tren App Store Connect

### Diem khac nhau quan trong giua Android va iOS cho AdMob

- App ID khac nhau theo nen tang
- Ad Unit ID khac nhau theo nen tang
- Android dung metadata trong manifest
- iOS dung `Info.plist`
- iOS can quan tam them `SKAdNetwork`, ATT, va App Privacy

### Phat hien quan trong trong code hien tai

Trong script `CommonScripts/ads/Rewarded.gd`, lenh load rewarded ad dang nam ben trong callback `on_ad_loaded`, nen logic do se khong bao gio bat dau load quảng cao rewarded.

Dieu nay khong nhat thiet chan export iOS, nhung neu script nay la script ban dinh dung cho production thi no can duoc sua truoc khi test ads that.

Ngoai ra, trong `CommonScripts/ads/Interstatial.gd` va `CommonScripts/ads/Rewarded.gd`, ban dang dung ad unit test cua Google. Khi len TestFlight hoac release that, doi sang ad unit iOS that cua ban.

## 4. Thu tu thao tac dung de len TestFlight

### Buoc A - Chuan bi Apple

1. Dang ky Apple Developer Program.
2. Tao App ID / Bundle ID trong Apple Developer neu chua co.
3. Tao app trong App Store Connect voi dung bundle ID do.

### Buoc B - Chuan bi Godot

1. Cai export templates dung version Godot 4.4.
2. Mo preset iOS va dien cac truong bat buoc.
3. Dien icon iOS.
4. Kiem tra privacy fields.
5. Neu su dung AdMob iOS, chuan bi `Info.plist` content va plugin iOS native.

### Buoc C - Export sang Xcode

1. Chon `Export Project` cho iOS.
2. Export vao mot thu muc rong.
3. Khong dat ten project export co dau cach.

### Buoc D - Cau hinh trong Xcode

1. Mo file `.xcodeproj` vua export.
2. Chon target app.
3. Vao `Signing & Capabilities`.
4. Chon Team.
5. Xac nhan Bundle Identifier dung voi App Store Connect.
6. Xac nhan Version va Build.
7. Neu dung AdMob, kiem tra `Info.plist`:
   - co `GADApplicationIdentifier`
   - co `SKAdNetworkItems`
8. Kiem tra icon, deployment target, va orientation.

### Buoc E - Chay tren may that truoc

1. Cam iPhone/iPad that vao Mac.
2. Chon dung thiet bi trong Xcode.
3. Build va run.
4. Test:
   - mo app co crash khong
   - gameplay chay duoc khong
   - luu du lieu co on khong
   - ads co goi SDK duoc khong
   - neu chua bat ads that, it nhat app phai chay on dinh khi plugin ton tai

### Buoc F - Archive va upload

1. Trong Xcode chon `Any iOS Device (arm64)` hoac thiet bi generic tuong duong.
2. `Product > Archive`.
3. Sau khi archive xong, trong Organizer chon `Distribute App`.
4. Chon upload len App Store Connect.
5. Cho build xu ly tren server Apple.

### Buoc G - Bat TestFlight

1. Mo App Store Connect.
2. Vao app cua ban.
3. Mo tab `TestFlight`.
4. Cho build xuat hien.
5. Dien `Beta App Description`, `What to Test`, va contact email.
6. Them `Internal Testers` truoc.
7. Khi on dinh moi them `External Testers`.

### Buoc H - Neu moi lan dau, cach an toan nhat

1. Len TestFlight ban dau voi app chay duoc tren iPhone, chua can ads that.
2. Sau khi quy trinh signing, upload, TestFlight da on dinh, moi bat hoan chinh AdMob iOS.
3. Sau cung moi toi uu privacy, tracking, mediation, va revenue.

## 5. Checklist ngan gon truoc khi bam Upload

- Bundle ID khop Apple Developer va App Store Connect
- Team ID dung
- Version va Build dung
- Icon iOS day du
- Build chay tren may that
- Neu co AdMob iOS: plugin native da cai
- `GADApplicationIdentifier` da them
- `SKAdNetworkItems` da them
- Privacy khai bao khop voi app that
- Dang dung ad unit iOS dung nen tang
