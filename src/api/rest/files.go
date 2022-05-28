package api_rest

import (
	"io"
	"net/http"
	"os"
)

func uploadFile(r *http.Request, username string) error {
	err := r.ParseMultipartForm(100000)
	if err != nil {
		return err
	}

	m := r.MultipartForm

	files := m.File["myfiles"]
	for i := range files {
		file, err := files[i].Open()
		if err != nil {
			return err
		}
		defer file.Close()

		dst, err := os.Create("../data/users/" + username + "/" + files[i].Filename)
		if err != nil {
			return err
		}
		defer dst.Close()

		if _, err := io.Copy(dst, file); err != nil {
			return err
		}
	}

	return nil
}
