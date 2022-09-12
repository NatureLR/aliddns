package ddns

import (
	"encoding/json"
	"io"
	"net/http"
	"strings"

	"github.com/naturelr/aliddns/pkg/ali"
	"github.com/robfig/cron/v3"
	"github.com/spf13/viper"
	"k8s.io/klog/v2"
)

type Server struct {
	LogLevel int `mapstructure:"v"`
	Key      string
	Cert     string
	Domain   string
	Cron     string
}

func NewServer() *Server {
	return &Server{}
}

func (s *Server) InitByVirper() {
	if err := viper.Unmarshal(s); err != nil {
		klog.Fatal(err)
	}

	if v, err := json.Marshal(&s); err != nil {
		klog.Warning(err)
	} else {
		klog.V(2).Infoln(string(v))
	}
}

func (s *Server) Run() error {
	d := strings.SplitN(strings.ToLower(s.Domain), ".", 2)
	if len(d) != 2 {
		klog.Fatalf("只支持一级域名如[%s],当前为[%s]", "test.example.com", s.Domain)
	}
	subDomain := d[0]
	domain := d[1]

	ali, err := ali.New(s.Key, s.Cert)
	if err != nil {
		return err
	}

	ip, err := GetIP()
	if err != nil {
		return err
	}
	err = ali.Save(subDomain, domain, ip)
	if err != nil {
		return err
	}

	cron := cron.New(cron.WithSeconds())
	cron.AddFunc(s.Cron, func() {
		ip, err = GetIP()
		err = ali.Save(subDomain, domain, ip)
	})
	cron.Run()

	return err
}

func GetIP() (string, error) {
	resp, err := http.Get("http://ipv4.ident.me")
	if err != nil {
		return "", err
	}
	ip, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}
	return string(ip), nil
}
