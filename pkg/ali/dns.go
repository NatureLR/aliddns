package ali

import (
	"github.com/aliyun/alibaba-cloud-sdk-go/sdk"
	"github.com/aliyun/alibaba-cloud-sdk-go/sdk/auth/credentials"
	alidns "github.com/aliyun/alibaba-cloud-sdk-go/services/alidns"
	"k8s.io/klog/v2"
)

type Client struct {
	DNS *alidns.Client
}

func New(key, secret string) (*Client, error) {
	config := sdk.NewConfig()
	credential := credentials.NewAccessKeyCredential(key, secret)
	client, err := alidns.NewClientWithOptions("cn-shanghai", config, credential)
	if err != nil {
		return nil, err
	}
	return &Client{client}, nil
}

func (c *Client) Get(domain string) (*alidns.DescribeDomainRecordsResponse, error) {
	request := alidns.CreateDescribeDomainRecordsRequest()
	request.Scheme = "https"
	request.DomainName = domain
	return c.DNS.DescribeDomainRecords(request)
}

func (c *Client) Update(RecordId, subDomain, kind, value string) (*alidns.UpdateDomainRecordResponse, error) {
	request := alidns.CreateUpdateDomainRecordRequest()
	request.Scheme = "https"
	request.RR = subDomain
	request.Type = kind
	request.Value = value
	request.RecordId = RecordId
	return c.DNS.UpdateDomainRecord(request)
}

func (c *Client) Add(domain, subDomain, kind, value string) (*alidns.AddDomainRecordResponse, error) {
	request := alidns.CreateAddDomainRecordRequest()
	request.Scheme = "https"
	request.DomainName = domain
	request.RR = subDomain
	request.Type = kind
	request.Value = value
	return c.DNS.AddDomainRecord(request)
}

// 域名存在则修改，域名不存在则创建
func (c *Client) Save(subDomain, domain, value string) error {
	AllDomain, err := c.Get(domain)
	if err != nil {
		return err
	}
	record := make(map[string]alidns.Record)
	for _, r := range AllDomain.DomainRecords.Record {
		record[r.RR] = r
	}

	// 存在则修改
	if r, ok := record[subDomain]; ok {
		if r.Value == value {
			klog.Warningf("%s.%s的值已经是:%s", r.RR, r.DomainName, value)
			return nil
		}
		res, err := c.Update(r.RecordId, subDomain, "A", value)
		if err != nil {
			return err
		}
		klog.Info(res)
		return nil
	}

	// 不存在就添加
	res, err := c.Add(domain, subDomain, "A", value)
	if err != nil {
		return err
	}
	klog.Info(res)
	return nil
}
