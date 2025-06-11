package main

import (
	"io"

	"html/template"
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"

	"go.uber.org/zap"
)

// Template struct for rendering HTML templates
type Template struct {
	templates *template.Template
}

func (t *Template) Render(w io.Writer, name string, data interface{}, c echo.Context) error {
	return t.templates.ExecuteTemplate(w, name, data)
}

func createTemplate() *Template {
	return &Template{
		templates: template.Must(template.ParseGlob("templates/*.html")),
	}
}

func main() {
	logger, _ := zap.NewProduction()

	e := echo.New()

	e.Renderer = createTemplate()

	e.Use(middleware.Recover())
	e.Use(middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{
		LogURI:    true,
		LogStatus: true,
		LogValuesFunc: func(c echo.Context, v middleware.RequestLoggerValues) error {
			logger.Info("request",
				zap.String("URI", v.URI),
				zap.Int("status", v.Status),
			)
			return nil
		},
	}))

	e.Static("/static", "static")

	// Define routes

	e.Logger.Fatal(e.Start(":8080"))
}
