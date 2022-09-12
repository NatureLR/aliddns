package ali

import (
	"testing"
)

const (
	KEY    = "<key>"
	SECRET = "<cert>"
)

func TestGET(t *testing.T) {
	client, err := New(KEY, SECRET)
	if err != nil {
		panic(err)
	}
	info, err := client.Get("naturelr.cc")
	if err != nil {
		panic(err)
	}
	t.Log(info)
}

func TestADD(t *testing.T) {
	client, err := New(KEY, SECRET)
	if err != nil {
		panic(err)
	}
	info, err := client.Add("naturelr.cc", "test", "A", "114.114.114.114")
	if err != nil {
		panic(err)
	}
	t.Log(info)
}

func TestUpdate(t *testing.T) {
	client, err := New(KEY, SECRET)
	if err != nil {
		panic(err)
	}
	info, err := client.Update("784081660121518080", "test", "A", "114.114.114.110")
	if err != nil {
		panic(err)
	}
	t.Log(info)
}

func TestSave(t *testing.T) {
	client, err := New(KEY, SECRET)
	if err != nil {
		panic(err)
	}
	err = client.Save("test", "naturelr.cc", "114.114.114.113")
	if err != nil {
		panic(err)
	}
}
