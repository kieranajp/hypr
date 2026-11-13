// wolverine-battery prints the battery level of a Razer Wolverine V3 Pro
// connected via its 2.4 GHz dongle, e.g. "62%" or "62% charging".
//
// Only works in PC mode (dongle USB ID 1532:0a4c; Function+Menu+A on the
// controller). Xbox mode (1532:0a3f) has no HID interface to ask.
//
// Protocol from https://github.com/T13nou/wolverine-v3-pro-battery: a 90-byte
// Razer feature report (ID 4) on the dongle's vendor hidraw interface. Like
// that tool, only known read-only commands are ever sent; other vendor
// commands change controller state.
//
// Exit codes: 0 ok, 1 dongle not found / not in PC mode, 2 controller not
// answering (asleep, off), 3 permission or I/O error.
package main

import (
	"bytes"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"syscall"
	"time"
	"unsafe"
)

const (
	reportID  = 0x04
	reportLen = 90
	bufLen    = reportLen + 1 // report ID prefix

	statusOK   = 0x02
	statusBusy = 0x01
)

// Razer feature report ioctls: _IOC(_IOC_READ|_IOC_WRITE, 'H', nr, len)
func hidioc(nr, length uintptr) uintptr { return 3<<30 | length<<16 | 'H'<<8 | nr }

var (
	hidiocSFeature = hidioc(0x06, bufLen)
	hidiocGFeature = hidioc(0x07, bufLen)

	// usage page 0xff00, report ID 4: the dongle's vendor interface
	descriptorSig = []byte{0x06, 0x00, 0xff, 0x85, 0x04}
)

type command struct{ class, id byte }

// Read-only commands only. Never add writes here.
var (
	cmdBattery  = command{0x07, 0x80}
	cmdCharging = command{0x07, 0x84}
	// Active onboard profile, 1-4 = Fn+A/B/X/Y on the pad. Read-only per
	// github.com/Netruk44/wolverine-v3-pro-linux docs/protocol.md.
	cmdProfile = command{0x05, 0x84}
)

var errNoAnswer = errors.New("controller not answering")

func findHidraw() (string, error) {
	nodes, _ := filepath.Glob("/sys/class/hidraw/hidraw*")
	for _, n := range nodes {
		uevent, err := os.ReadFile(filepath.Join(n, "device", "uevent"))
		if err != nil || !bytes.Contains(bytes.ToUpper(uevent), []byte("00001532:00000A4C")) {
			continue
		}
		desc, err := os.ReadFile(filepath.Join(n, "device", "report_descriptor"))
		if err != nil || !bytes.Contains(desc, descriptorSig) {
			continue
		}
		return "/dev/" + filepath.Base(n), nil
	}
	return "", errors.New("dongle not found in PC mode (1532:0a4c)")
}

func ioctl(fd int, req uintptr, buf []byte) error {
	_, _, e := syscall.Syscall(syscall.SYS_IOCTL, uintptr(fd), req, uintptr(unsafe.Pointer(&buf[0])))
	if e != 0 {
		return e
	}
	return nil
}

// query sends c, retrying a few times: the first request after the pad has
// been idle often fails while the dongle wakes the link.
func query(fd int, c command) ([]byte, error) {
	var err error
	for attempt := range 4 {
		if attempt > 0 {
			time.Sleep(time.Duration(attempt) * 150 * time.Millisecond)
		}
		var data []byte
		if data, err = queryOnce(fd, c); err == nil || !errors.Is(err, errNoAnswer) {
			return data, err
		}
	}
	return nil, err
}

func queryOnce(fd int, c command) ([]byte, error) {
	req := make([]byte, bufLen)
	req[0] = reportID
	r := req[1:]
	r[1] = 0x1f // transaction id
	r[5] = 2    // data size
	r[6], r[7] = c.class, c.id
	var crc byte
	for _, b := range r[2:88] {
		crc ^= b
	}
	r[88] = crc

	if err := ioctl(fd, hidiocSFeature, req); err != nil {
		return nil, fmt.Errorf("send: %w", err)
	}
	for range 10 {
		time.Sleep(20 * time.Millisecond)
		resp := make([]byte, bufLen)
		resp[0] = reportID
		if err := ioctl(fd, hidiocGFeature, resp); err != nil {
			return nil, fmt.Errorf("receive: %w", err)
		}
		p := resp[1:]
		switch {
		case p[0] == statusBusy:
			continue
		case p[0] == statusOK && p[6] == c.class && p[7] == c.id:
			n := max(int(p[5]), 1)
			return p[8 : 8+n], nil
		default:
			return nil, errNoAnswer
		}
	}
	return nil, errNoAnswer
}

func run(args []string) (string, int) {
	dev, err := findHidraw()
	if err != nil {
		return err.Error(), 1
	}
	f, err := os.OpenFile(dev, os.O_RDWR, 0)
	if err != nil {
		return err.Error(), 3
	}
	defer f.Close()
	fd := int(f.Fd())

	if len(args) > 0 && args[0] == "profile" {
		p, err := query(fd, cmdProfile)
		if err != nil {
			if errors.Is(err, errNoAnswer) {
				return err.Error(), 2
			}
			return err.Error(), 3
		}
		return fmt.Sprintf("%d", p[0]), 0
	}

	bat, err := query(fd, cmdBattery)
	if err != nil {
		if errors.Is(err, errNoAnswer) {
			return err.Error(), 2
		}
		return err.Error(), 3
	}
	pct := (int(bat[len(bat)-1])*100 + 127) / 255

	out := []string{fmt.Sprintf("%d%%", pct)}
	if chg, err := query(fd, cmdCharging); err == nil && chg[len(chg)-1] != 0 {
		out = append(out, "charging")
	}
	return strings.Join(out, " "), 0
}

func main() {
	msg, code := run(os.Args[1:])
	if code == 0 {
		fmt.Println(msg)
	} else {
		fmt.Fprintln(os.Stderr, "wolverine-battery:", msg)
	}
	os.Exit(code)
}
