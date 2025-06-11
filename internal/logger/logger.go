package logger

import (
	"log"

	"go.uber.org/zap"
)

func CreateLogger() *zap.Logger {
	logger, err := zap.NewProduction()
	if err != nil {
		log.Fatalf("Failed to create logger: %v", err)
	}
	return logger
}
