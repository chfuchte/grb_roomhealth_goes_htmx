package main

import (
	"context"
	"database/sql"
	"html/template"
	"io"
	"net/http"

	"chfuchte.de/grb_roomhealth_goes_htmx/internal/logger"
	_ "github.com/go-sql-driver/mysql"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/labstack/gommon/log"
	"go.uber.org/zap"
)

type Head struct {
	Title string
}

type TemplateData struct {
	Head Head
}

type Template struct {
	templates *template.Template
}

func (t *Template) Render(w io.Writer, name string, data any, c echo.Context) error {
	return t.templates.ExecuteTemplate(w, name, data)
}

func createTemplates() *Template {
	return &Template{
		templates: template.Must(template.ParseGlob("templates/**/*.html")),
	}
}

func createDatabaseConnection(ctx context.Context) (*sql.DB, error) {
	dbCon, err := sql.Open("mysql", "rh:rh_pwd@/rh?parseTime=true&multiStatements=true")
	if err != nil {
		return nil, err
	}
	if err := dbCon.PingContext(ctx); err != nil {
		return nil, err
	}
	return dbCon, nil
}

func main() {
	// set up the logger
	logger := logger.CreateLogger()
	defer logger.Sync()

	// set up the database connection
	dbCtx := context.Background()
	dbCon, err := createDatabaseConnection(dbCtx)
	if err != nil {
		logger.Fatal("failed to connect to database", zap.Error(err))
	}
	defer func() {
		if err := dbCon.Close(); err != nil {
			logger.Error("failed to close database connection", zap.Error(err))
		}
	}()

	// db := database.New(dbCon)

	// set up echo instance
	e := echo.New()
	e.HTTPErrorHandler = httpErrorHandler(logger)
	e.Renderer = createTemplates()
	// add some middlewares
	e.Use(middleware.RecoverWithConfig(middleware.RecoverConfig{ // recover from panics
		LogLevel: log.ERROR,
		LogErrorFunc: func(c echo.Context, err error, stack []byte) error {
			logger.Error("echo::recover::panic_recovered",
				zap.Error(err),
				zap.ByteString("stack", stack),
			)
			return nil
		},
	}))
	e.Use(middleware.CSRF())                                                 // CSRF protection
	e.Use(middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{ // log requests nicely
		LogMethod: true,
		LogURI:    true,
		LogStatus: true,
		LogValuesFunc: func(c echo.Context, v middleware.RequestLoggerValues) error {
			logger.Info("request",
				zap.String("method", v.Method),
				zap.String("uri", v.URI),
				zap.Int("status", v.Status),
			)
			return nil
		},
	}))
	e.Use(middleware.BodyLimit("2M")) // 2MB

	// TODO: add more routes here

	// serve static files from the "static" directory
	e.Static("/static", "static")

	e.GET("/", func(c echo.Context) error {
		return c.Render(http.StatusOK, "page:index:public", TemplateData{
			Head: Head{
				Title: "Welcome",
			},
		})
	})

	// catch-all route to return a ui for unmatched routes
	e.GET("/*", func(c echo.Context) error {
		return c.Render(http.StatusNotFound, "page:NOT_FOUND", TemplateData{
			Head: Head{
				Title: "Not Found",
			},
		})
	})

	e.Logger.Fatal(e.Start(":8080"))
}

func httpErrorHandler(logger *zap.Logger) echo.HTTPErrorHandler {
	return func(err error, c echo.Context) {
		code := http.StatusInternalServerError
		if he, ok := err.(*echo.HTTPError); ok {
			code = he.Code
		}
		logger.Error("http_error", zap.Error(err), zap.Int("status", code))
		c.String(code, "Internal Server Error")
	}
}
