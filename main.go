package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/jackc/pgx/v4/pgxpool"
)

func main() {
	fmt.Println("starting application")
	initDb()
	initApp()
}

func initDb() {
	fmt.Println("Trying to start DB")
	var dbConnString string = os.Getenv("DATABASE_URL")
	if dbConnString == "" {
		fmt.Println("DATABASE_URL env value is not setup. Please setup one.")
		os.Exit(1)
	}
	dbpool, err := pgxpool.Connect(context.Background(), dbConnString)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
	defer dbpool.Close()

	var helloWorldSqlOutput string
	err = dbpool.QueryRow(context.Background(), "select 'Hello World !!!'").Scan(&helloWorldSqlOutput)

	if err != nil {
		fmt.Fprintf(os.Stderr, "QueryRow failed: %v\n", err)
		os.Exit(1)
	}
	// Uncomment below line to see the ouput in the terminal
	fmt.Println(helloWorldSqlOutput)

	fmt.Println("Hurray, database sucessfully connected.")
}

func initApp() {
	// Function to handle '/healthz' request
	http.HandleFunc("/healthz", HealthServer)

	// Server message printed in logs
	fmt.Println("Server started at port 8080")

	log.Fatal(http.ListenAndServe(":8080", nil))
	log.Printf("app is up and running with db backend")
}

func HealthServer(w http.ResponseWriter, r *http.Request) {
	fmt.Println("starting application got request for health")
	fmt.Fprintln(w, "The app is up and running.")
}
