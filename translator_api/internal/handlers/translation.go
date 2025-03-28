package handlers

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

// DeepL API URL
const deepLAPIURL = "https://api-free.deepl.com/v2/translate"

// TranslationHandler, çeviri API isteklerini işler
type TranslationHandler struct {
	APIKey string
}

// NewTranslationHandler, yeni bir TranslationHandler oluşturur
func NewTranslationHandler(apiKey string) *TranslationHandler {
	return &TranslationHandler{
		APIKey: apiKey,
	}
}

// TranslationRequest, çeviri isteği için JSON yapısı
type TranslationRequest struct {
	Text          string `json:"text"`
	SourceLang    string `json:"source_lang"`
	TargetLang    string `json:"target_lang"`
}

// TranslationResponse, çeviri yanıtı için JSON yapısı
type TranslationResponse struct {
	TranslatedText string `json:"translated_text,omitempty"`
	Error          string `json:"error,omitempty"`
}

// DeepLRequest, DeepL API'ye gönderilecek istek
type DeepLRequest struct {
	Text       []string `json:"text"`
	SourceLang string   `json:"source_lang,omitempty"`
	TargetLang string   `json:"target_lang"`
}

// DeepLResponse, DeepL API'den gelen yanıt
type DeepLResponse struct {
	Translations []struct {
		Text string `json:"text"`
	} `json:"translations"`
}

// Translate, metni çevirir
func (h *TranslationHandler) Translate(w http.ResponseWriter, r *http.Request) {
	// Sadece POST isteklerini işle
	if r.Method != http.MethodPost {
		http.Error(w, "Sadece POST metodu destekleniyor", http.StatusMethodNotAllowed)
		return
	}

	// JSON içeriği oku
	var req TranslationRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Geçersiz JSON içeriği", http.StatusBadRequest)
		return
	}

	// Gerekli alanları kontrol et
	if req.Text == "" || req.TargetLang == "" {
		http.Error(w, "Metin ve hedef dil gereklidir", http.StatusBadRequest)
		return
	}

	// DeepL API isteğini oluştur
	deepLReq := DeepLRequest{
		Text:       []string{req.Text},
		TargetLang: req.TargetLang,
	}

	// Kaynak dil belirtildiyse ekle
	if req.SourceLang != "" {
		deepLReq.SourceLang = req.SourceLang
	}

	// İstek verilerini JSON'a dönüştür
	reqBody, err := json.Marshal(deepLReq)
	if err != nil {
		http.Error(w, "İstek hazırlanırken hata oluştu", http.StatusInternalServerError)
		return
	}

	// DeepL API'ye istek gönder
	client := &http.Client{}
	deepLReqObj, err := http.NewRequest("POST", deepLAPIURL, bytes.NewBuffer(reqBody))
	if err != nil {
		http.Error(w, "API isteği oluşturulurken hata oluştu", http.StatusInternalServerError)
		return
	}

	deepLReqObj.Header.Set("Authorization", fmt.Sprintf("DeepL-Auth-Key %s", h.APIKey))
	deepLReqObj.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(deepLReqObj)
	if err != nil {
		http.Error(w, "API isteği yapılırken hata oluştu", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	// Başarısız durum kodlarını kontrol et
	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		errMsg := fmt.Sprintf("DeepL API hatası: %s - %s", resp.Status, string(bodyBytes))
		
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(resp.StatusCode)
		json.NewEncoder(w).Encode(TranslationResponse{
			Error: errMsg,
		})
		return
	}

	// Yanıtı oku ve işle
	var deepLResp DeepLResponse
	if err := json.NewDecoder(resp.Body).Decode(&deepLResp); err != nil {
		http.Error(w, "API yanıtı işlenirken hata oluştu", http.StatusInternalServerError)
		return
	}

	// Çeviri sonucunu döndür
	if len(deepLResp.Translations) > 0 {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(TranslationResponse{
			TranslatedText: deepLResp.Translations[0].Text,
		})
	} else {
		http.Error(w, "API yanıtında çeviri bulunamadı", http.StatusInternalServerError)
	}
}

// Language yapısı
type Language struct {
	Code string `json:"code"`
	Name string `json:"name"`
}

// GetLanguages, desteklenen dilleri döndürür
func (h *TranslationHandler) GetLanguages(w http.ResponseWriter, r *http.Request) {
	// Sadece GET isteklerini işle
	if r.Method != http.MethodGet {
		http.Error(w, "Sadece GET metodu destekleniyor", http.StatusMethodNotAllowed)
		return
	}

	// Desteklenen diller listesi (basitleştirilmiş)
	languages := []Language{
		{Code: "TR", Name: "Türkçe"},
		{Code: "EN", Name: "İngilizce"},
		{Code: "DE", Name: "Almanca"},
		{Code: "FR", Name: "Fransızca"},
		{Code: "ES", Name: "İspanyolca"},
		{Code: "IT", Name: "İtalyanca"},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(languages)
} 