package handlers

import (
	"encoding/json"
	"net/http"
	"time"
)

// HealthResponse, sağlık kontrolü yanıtı
type HealthResponse struct {
	Status  string    `json:"status"`
	Message string    `json:"message"`
	Time    time.Time `json:"time"`
}

// HealthCheck, API'nin çalışır durumda olduğunu doğrular
func HealthCheck(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status:  "up",
		Message: "API çalışıyor",
		Time:    time.Now(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
} 