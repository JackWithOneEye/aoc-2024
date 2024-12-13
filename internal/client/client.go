package client

import (
	"io"
	"log"
	"net"
)

type client struct {
	conn *net.TCPConn
}

func NewClient() io.ReadWriteCloser {
	tcpAddr, err := net.ResolveTCPAddr("tcp", "127.0.0.1:3667")
	if err != nil {
		log.Fatalf("could not resolve tcp addr: %s", err)
	}
	conn, err := net.DialTCP("tcp", nil, tcpAddr)
	if err != nil {
		log.Fatalf("could not dial tcp connection: %s", err)
	}

	return &client{conn}
}

func (c *client) Read(p []byte) (n int, err error) {
	return c.conn.Read(p)
}

func (c *client) Write(p []byte) (n int, err error) {
	return c.conn.Write(p)
}

func (c *client) Close() error {
	return c.conn.Close()
}
