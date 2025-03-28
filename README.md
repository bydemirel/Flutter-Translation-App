# Çeviri Uygulaması

Bu proje, çevrimiçi ve çevrimdışı çalışabilen bir çeviri uygulamasıdır. Flutter ile geliştirilmiş modern bir kullanıcı arayüzüne ve Go ile yazılmış güçlü bir arka uca sahiptir.

## Özellikler

- DeepL API'si kullanarak yüksek kaliteli çeviriler
- Çevrimdışı kullanım için çevirileri yerel depolama
- Sık kullanılan çevirileri favorilere ekleme
- Çeviri geçmişini görüntüleme
- Çoklu dil desteği
- Modern ve kullanıcı dostu arayüz

## Mimari Yapı

### Frontend (Flutter)
- Hive ile yerel veritabanı yönetimi
- DeepL API'yi çevrimiçi çeviriler için kullanma
- Çevrimdışı modda, önceden kaydedilen çevirileri getirme

### Backend (Go - REST API)
- Çeviri isteklerini DeepL API'ye yönlendirme
- Kullanıcı geçmişini yönetme
- Çevrimdışı veri setleri sağlama

## Kurulum

### Gereksinimler
- Flutter SDK
- Go 1.16+
- DeepL API anahtarı

### Flutter Uygulaması
1. Uygulamanın kök dizininde `.env` dosyasını oluşturun ve DeepL API anahtarınızı ekleyin:
   ```
   DEEPL_API_KEY=your_api_key_here
   API_URL=http://localhost:8080/api
   ```

2. Bağımlılıkları yükleyin:
   ```bash
   cd translator_app
   flutter pub get
   ```

3. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

### Go API
1. API'nin kök dizininde `.env` dosyasını oluşturun:
   ```
   DEEPL_API_KEY=your_api_key_here
   PORT=8080
   ```

2. Bağımlılıkları yükleyin:
   ```bash
   cd translator_api
   go mod download
   ```

3. API'yi çalıştırın:
   ```bash
   go run cmd/api/main.go
   ```

## Lisans

MIT

## İletişim

Bu proje hakkında sorularınız veya önerileriniz varsa, lütfen iletişime geçin. 