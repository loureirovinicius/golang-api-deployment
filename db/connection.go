package db

import (
	"crud/config"
	"database/sql"
	"fmt"

	_ "github.com/lib/pq"
)

func OpenConnection() (*sql.DB, error) {
	conf := config.GetDB()

	sc := fmt.Sprintf("postgres://%v:%v@%v:%v/%v?sslmode=disable", conf.User, conf.Pass, conf.Host, conf.Port, conf.Database)

	conn, err := sql.Open("postgres", sc)
	if err != nil {
		panic(err)
	}

	err = conn.Ping()

	return conn, err
}
