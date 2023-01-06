package main

import (
	"crud/config"
	"crud/handlers"
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
)

func main() {
	err := config.Load()
	if err != nil {
		panic(err)
	}

	config.Load()

	r := chi.NewRouter()

	r.Get("/", handlers.GetAll)
	r.Get("/{id}", handlers.Get)
	r.Post("/", handlers.Create)
	r.Put("/{id}", handlers.Update)
	r.Delete("/{id}", handlers.Delete)

	fmt.Printf("Server started and listening on port %s.\n", config.GetServerPort())
	http.ListenAndServe(fmt.Sprintf(":%s", config.GetServerPort()), r)
}
