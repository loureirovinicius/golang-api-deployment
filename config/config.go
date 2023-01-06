package config

import "github.com/spf13/viper"

var cfg *config

type config struct {
	API APIConfig
	DB  DBConfig
}

type APIConfig struct {
	Port string
}

type DBConfig struct {
	Host     string
	Port     string
	User     string
	Pass     string
	Database string
}

func init() {
	viper.SetDefault("API_PORT", "9000")
	viper.SetDefault("HOST", "localhost")
	viper.SetDefault("DB_PORT", "5432")
}

func Load() error {
	viper.SetConfigName("configs")
	viper.SetConfigType("env")
	viper.AddConfigPath(".")
	err := viper.ReadInConfig()
	if err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			return err
		}
	}

	viper.AutomaticEnv()

	cfg = new(config)

	cfg.API = APIConfig{
		Port: viper.GetString("API_PORT"),
	}

	cfg.DB = DBConfig{
		Host:     viper.GetString("HOST"),
		Port:     viper.GetString("DB_PORT"),
		User:     viper.GetString("PGUSER"),
		Pass:     viper.GetString("PGPASSWORD"),
		Database: viper.GetString("DB_NAME"),
	}

	return nil
}

func GetDB() DBConfig {
	return cfg.DB
}

func GetServerPort() string {
	return cfg.API.Port
}
