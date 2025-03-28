package main

import (
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
	"github.com/yourusername/translator_api/internal/handlers"
)

func main() {
	// .env dosyasını yükle
	err := godotenv.Load()
	if err != nil {
		log.Println("Uyarı: .env dosyası bulunamadı")
	}

	// DeepL API anahtarını kontrol et
	apiKey := os.Getenv("DEEPL_API_KEY")
	if apiKey == "" {
		log.Fatal("DEEPL_API_KEY çevre değişkeni ayarlanmalıdır")
	}

	// Çeviri handler'ını oluştur
	translationHandler := handlers.NewTranslationHandler(apiKey)

	// API rotalarını tanımla
	http.HandleFunc("/api/translate", translationHandler.Translate)
	http.HandleFunc("/api/languages", translationHandler.GetLanguages)
	http.HandleFunc("/api/health", handlers.HealthCheck)

	// Statik dosyaları sunmak için
	fs := http.FileServer(http.Dir("./static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	// Sunucuyu başlat
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("API sunucusu http://localhost:%s adresinde çalışıyor\n", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
} 