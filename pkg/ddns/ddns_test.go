package ddns

import (
	"fmt"
	"testing"
)

func TestGetIP(t *testing.T) {
	ip, err := GetIP()
	if err != nil {
		panic(err)
	}
	fmt.Println(ip)
}

func TestRun(t *testing.T) {
	s := &Server{
		Key:    "<key>",
		Cert:   "<cert>",
		Cron:   "* * * * *",
		Domain: "test.naturelr.cc",
	}
	if err := s.Run(); err != nil {
		panic(err)
	}
}
