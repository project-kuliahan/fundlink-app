# FundLink App

FundLink App adalah aplikasi mobile berbasis Flutter untuk membantu pengelolaan administrasi keuangan unit. Aplikasi ini menyediakan fitur login, dashboard saldo, pencatatan pemasukan dan pengeluaran, riwayat transaksi, statistik, ekspor laporan, notifikasi, serta halaman profil pengguna.

Project ini menggunakan Flutter dengan state management `flutter_bloc`, penyimpanan lokal melalui `shared_preferences`, komunikasi REST API menggunakan `http`, grafik menggunakan `fl_chart`, serta fitur ekspor dan berbagi file menggunakan `csv`, `path_provider`, dan `share_plus`.

## Daftar Isi

- [Fitur Utama](#fitur-utama)
- [Teknologi](#teknologi)
- [Arsitektur Project](#arsitektur-project)
- [Struktur Folder](#struktur-folder)
- [Backend API](#backend-api)
- [Model Data Utama](#model-data-utama)
- [Persyaratan Sistem](#persyaratan-sistem)
- [Instalasi dan Menjalankan Project](#instalasi-dan-menjalankan-project)
- [Build Aplikasi](#build-aplikasi)
- [Alur Penggunaan Aplikasi](#alur-penggunaan-aplikasi)
- [State Management](#state-management)
- [Penyimpanan Lokal](#penyimpanan-lokal)
- [Upload Gambar](#upload-gambar)
- [Ekspor Laporan](#ekspor-laporan)
- [Testing](#testing)
- [Konvensi Pengembangan](#konvensi-pengembangan)
- [Troubleshooting](#troubleshooting)

## Fitur Utama

### Autentikasi

- Login menggunakan email dan password.
- Token autentikasi disimpan secara lokal.
- Splash screen memeriksa token sebelum menentukan halaman awal.
- Logout menghapus token dan data pengguna lokal.
- Jika sesi tidak valid atau API mengembalikan status `401`, token dan data pengguna lokal akan dihapus.

### Dashboard

- Menampilkan saldo aktif.
- Menampilkan total pemasukan.
- Menampilkan total pengeluaran.
- Menampilkan transaksi terbaru.
- Mendukung refresh data dengan pull-to-refresh.

### Transaksi

- Menampilkan riwayat transaksi.
- Filter transaksi berdasarkan:
  - Mingguan
  - Bulanan
  - Tahunan
- Input transaksi pemasukan.
- Input transaksi pengeluaran.
- Kategori pemasukan:
  - Donasi
  - Iuran
  - Pendapatan Usaha
  - Bantuan
  - Lainnya
- Kategori pengeluaran:
  - Operasional
  - Gaji
  - Transportasi
  - Perawatan
  - Konsumsi
  - Lainnya
- Detail transaksi.
- Upload foto bukti transaksi dari kamera atau galeri.

### Statistik

- Visualisasi pemasukan dan pengeluaran menggunakan bar chart.
- Filter statistik berdasarkan periode mingguan, bulanan, dan tahunan.
- Ringkasan total pemasukan dan pengeluaran berdasarkan filter aktif.
- Daftar transaksi hasil filter.

### Laporan

- Filter laporan berdasarkan periode.
- Ekspor laporan transaksi ke file CSV.
- Membagikan file laporan melalui share sheet perangkat.

### Notifikasi

- Mengambil daftar notifikasi dari backend.
- Menampilkan judul dan pesan notifikasi.

### Profil

- Menampilkan informasi pengguna:
  - Nama
  - Email
  - Role
  - Nomor telepon
  - Unit
  - Status verifikasi email
- Modal edit profil.
- Modal ubah password.
- Toggle notifikasi lokal di UI.
- Logout.

### Pengaturan Aplikasi

- Dukungan tema light dan dark melalui `AppSettingsCubit`.
- Dukungan locale default Indonesia (`id`).
- Preferensi tema dan bahasa disimpan di `shared_preferences`.

## Teknologi

| Kategori | Teknologi |
| --- | --- |
| Framework | Flutter |
| Bahasa | Dart |
| State management | flutter_bloc |
| HTTP client | http |
| Local storage | shared_preferences |
| Chart | fl_chart |
| Export CSV | csv |
| File temporary | path_provider |
| Share file | share_plus |
| Image picker | image_picker |
| Linting | flutter_lints |

## Arsitektur Project

Project ini menggunakan pendekatan berlapis yang memisahkan kode berdasarkan tanggung jawab:

```text
Presentation Layer
UI, halaman, widget, BLoC, Cubit

Domain Layer
Entity, repository contract, use case

Data Layer
Datasource, model, repository implementation

Core Layer
Komponen reusable, konstanta, formatter, API client, exception, extension
```

Pemisahan ini membuat kode lebih mudah dirawat karena tampilan, business logic, akses API, dan utilitas umum tidak dicampur dalam satu tempat.

## Struktur Folder

```text
lib/
  core/
    components/      Komponen UI reusable seperti button, text field, spacing, icon
    constants/       Warna, limit aplikasi, dan export konstanta
    dummy/           Data dummy transaksi
    error/           Exception untuk API, validasi, server, rate limit, unauthorized
    extensions/      Extension untuk context dan helper navigasi
    network/         ApiClient untuk komunikasi REST API
    utils/           Formatter rupiah dan filter transaksi

  data/
    datasources/     Remote datasource dan local datasource
    models/          Model response API
    repositories/    Implementasi repository

  domain/
    entities/        Entity domain
    repositories/    Contract repository
    usecases/        Use case aplikasi

  presentation/
    bloc/            AuthBloc, DashboardBloc, TransactionBloc, AppSettingsCubit
    ui/
      intro/         SplashPage dan LoginPage
      home/
        pages/       Halaman utama aplikasi
        widgets/     Widget pendukung halaman home

  main.dart          Entry point aplikasi
```

Folder platform:

```text
android/             Konfigurasi Android
ios/                 Konfigurasi iOS
web/                 Konfigurasi Flutter Web
linux/               Konfigurasi Linux desktop
macos/               Konfigurasi macOS desktop
windows/             Konfigurasi Windows desktop
test/                Unit/widget test
```

## Backend API

Base URL API dikonfigurasi di:

```dart
lib/core/network/api_client.dart
```

Nilai saat ini:

```text
https://bahamud.my.id/api
```

Endpoint yang digunakan aplikasi:

| Fitur | Method | Endpoint | Keterangan |
| --- | --- | --- | --- |
| Login | POST | `/login` | Login user dan mendapatkan token |
| User aktif | GET | `/user` | Mengambil profil user aktif |
| Logout | POST | `/logout` | Logout user |
| Dashboard | GET | `/dashboard` | Mengambil saldo, pemasukan, pengeluaran, dan unit |
| Transaksi | GET | `/transactions?page={page}` | Mengambil daftar transaksi dengan pagination |
| Buat transaksi | POST | `/transactions` | Membuat transaksi baru, mendukung multipart jika ada gambar |
| Notifikasi | GET | `/notifications?page={page}` | Mengambil daftar notifikasi |

Header default:

```text
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
```

Untuk upload gambar, request menggunakan `MultipartRequest` dengan header:

```text
Accept: application/json
Authorization: Bearer {token}
```

## Model Data Utama

### UserModel

Digunakan untuk menyimpan data pengguna dari endpoint `/user` dan response login.

Field utama:

- `id`
- `name`
- `email`
- `phone`
- `role`
- `unitId`
- `unitName`
- `emailVerifiedAt`

### DashboardModel

Digunakan untuk data ringkasan dashboard.

Field:

- `saldo`
- `totalPemasukan`
- `totalPengeluaran`
- `unitId`
- `unitName`

### TransactionModel

Digunakan untuk data transaksi.

Field:

- `id`
- `type`
- `amount`
- `category`
- `description`
- `transactionDate`
- `createdAt`
- `imageUrl`

Nilai `type` yang dianggap sebagai pemasukan:

```text
pemasukan
```

Selain itu akan diperlakukan sebagai pengeluaran pada beberapa tampilan.

### NotificationModel

Digunakan untuk data notifikasi.

Field umum yang dipakai halaman notifikasi:

- `title`
- `message`

## Persyaratan Sistem

Pastikan perangkat development memiliki:

- Flutter SDK sesuai constraint project
- Dart SDK sesuai Flutter yang digunakan
- Android Studio atau Android SDK untuk menjalankan Android
- Xcode untuk menjalankan iOS, khusus macOS
- Emulator Android, iOS Simulator, atau perangkat fisik

Constraint Dart SDK di `pubspec.yaml`:

```yaml
environment:
  sdk: ^3.10.7
```

## Instalasi dan Menjalankan Project

1. Masuk ke folder project:

```bash
cd fundlink_app
```

2. Ambil dependency:

```bash
flutter pub get
```

3. Pastikan device tersedia:

```bash
flutter devices
```

4. Jalankan aplikasi:

```bash
flutter run
```

Jika ingin menjalankan di device tertentu:

```bash
flutter run -d <device-id>
```

Contoh untuk Chrome:

```bash
flutter run -d chrome
```

## Build Aplikasi

### Android APK

```bash
flutter build apk --release
```

Output biasanya berada di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle

```bash
flutter build appbundle --release
```

Output biasanya berada di:

```text
build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
flutter build ios --release
```

Build iOS membutuhkan macOS dan Xcode.

### Web

```bash
flutter build web
```

Output berada di:

```text
build/web
```

## Alur Penggunaan Aplikasi

1. Aplikasi menampilkan `SplashPage`.
2. `SplashPage` mengecek token dari `SharedPreferences`.
3. Jika token tersedia, user diarahkan ke `MainPage`.
4. Jika token tidak tersedia, user diarahkan ke `LoginPage`.
5. User login menggunakan email dan password.
6. Setelah login berhasil, token dan data user disimpan secara lokal.
7. User masuk ke halaman utama dengan bottom navigation:
   - Beranda
   - Transaksi
   - Statistik
   - Profil
8. User dapat mencatat pemasukan atau pengeluaran dari halaman transaksi.
9. User dapat melihat statistik dan mengekspor laporan transaksi.
10. User dapat logout dari halaman profil.

## State Management

Project menggunakan `flutter_bloc`.

### AuthBloc

Mengelola autentikasi.

Event:

- `CheckAuthEvent`
- `LoginEvent`
- `LogoutEvent`

State:

- `AuthInitial`
- `AuthLoading`
- `AuthSuccess`
- `AuthFailure`
- `AuthLogout`

### DashboardBloc

Mengelola data dashboard.

Event:

- `LoadDashboard`

State:

- `DashboardInitial`
- `DashboardLoading`
- `DashboardLoaded`
- `DashboardFailure`

### TransactionBloc

Mengelola daftar transaksi dan input transaksi.

Event:

- `LoadTransactions`
- `CreateTransaction`

State:

- `TransactionInitial`
- `TransactionLoading`
- `TransactionsLoaded`
- `TransactionCreated`
- `TransactionFailure`

### AppSettingsCubit

Mengelola pengaturan aplikasi.

State:

- `AppSettings`

Data yang dikelola:

- `themeMode`
- `locale`

## Penyimpanan Lokal

Penyimpanan lokal menggunakan `shared_preferences`.

File utama:

```text
lib/data/datasources/auth_local_datasource.dart
lib/presentation/bloc/app_settings_cubit.dart
```

Key yang digunakan untuk autentikasi:

```text
token
user_data
```

Key yang digunakan untuk pengaturan:

```text
theme_mode
locale
```

## Upload Gambar

Input transaksi mendukung upload foto bukti dari:

- Kamera
- Galeri

Package yang digunakan:

```yaml
image_picker
```

Batas ukuran gambar:

```text
250 KB
```

Konfigurasi batas ukuran berada di:

```text
lib/core/constants/app_limits.dart
```

Jika ukuran gambar melebihi batas, aplikasi akan menampilkan pesan error dan transaksi tidak dikirim.

## Ekspor Laporan

Halaman laporan mengekspor transaksi ke file CSV berdasarkan filter periode.

Package yang digunakan:

- `csv`
- `path_provider`
- `share_plus`

Data CSV berisi:

- Tanggal
- Keterangan
- Kategori
- Jenis transaksi
- Nominal
- Total pemasukan
- Total pengeluaran

File dibuat di temporary directory perangkat, lalu dibagikan melalui fitur share.

## Testing

Menjalankan test:

```bash
flutter test
```

Catatan: file `test/widget_test.dart` masih berisi template default counter test dari Flutter. Karena aplikasi ini sudah tidak menggunakan counter starter app, test tersebut perlu diperbarui agar sesuai dengan alur FundLink, misalnya:

- Splash page tampil dengan teks FundLink.
- Login page menampilkan input email dan sandi.
- Validasi form transaksi berjalan.
- Formatter rupiah menghasilkan format yang benar.
- Filter transaksi mingguan, bulanan, dan tahunan berjalan sesuai data.

## Konvensi Pengembangan

Beberapa pola yang digunakan di project ini:

- Komponen umum diletakkan di `lib/core/components`.
- Konstanta warna menggunakan `AppColors`.
- Format mata uang menggunakan helper formatter di `lib/core/utils`.
- Navigasi menggunakan extension pada `BuildContext`.
- Akses API dilakukan melalui `ApiClient`.
- Business logic halaman utama dikelola melalui BLoC/Cubit.
- Data dari API dipetakan ke model di folder `data/models`.

Saat menambah fitur baru, ikuti struktur berikut:

```text
1. Tambahkan model di data/models jika response API baru diperlukan.
2. Tambahkan datasource di data/datasources untuk akses API.
3. Tambahkan repository/usecase jika fitur membutuhkan lapisan domain.
4. Tambahkan BLoC/Cubit jika fitur memiliki state kompleks.
5. Tambahkan UI di presentation/ui.
6. Tambahkan komponen reusable ke core/components jika dipakai lintas halaman.
```

## Troubleshooting

### Dependency gagal diambil

Jalankan:

```bash
flutter clean
flutter pub get
```

### Build Android gagal karena konfigurasi lokal

Pastikan Android SDK sudah terpasang dan `android/local.properties` berisi path SDK yang benar. File ini bersifat lokal dan sebaiknya tidak di-commit.

### Login gagal

Periksa:

- Koneksi internet.
- Base URL API di `ApiClient`.
- Credential user.
- Response backend untuk endpoint `/login`.

### Token expired atau unauthorized

Jika API mengembalikan `401`, aplikasi akan menghapus token dan data user lokal. User perlu login ulang.

### Gambar gagal diupload

Periksa:

- Ukuran gambar tidak lebih dari 250 KB.
- Permission kamera atau galeri sudah diberikan.
- Endpoint `/transactions` menerima multipart dengan field file bernama `image`.

### Data transaksi kosong

Periksa:

- User sudah login.
- Token valid.
- Endpoint `/transactions?page=1` mengembalikan data.
- Filter periode tidak sedang memilih periode tanpa transaksi.

## Informasi Project

| Item | Nilai |
| --- | --- |
| Nama package | `fundlink_app` |
| Nama aplikasi | FundLink |
| Versi | `1.0.0+1` |
| Bahasa default | Indonesia |
| Base API | `https://bahamud.my.id/api` |

## Lisensi

Belum ada informasi lisensi khusus di repository ini. Tambahkan file `LICENSE` jika project akan dipublikasikan atau dibagikan ke pihak lain.
