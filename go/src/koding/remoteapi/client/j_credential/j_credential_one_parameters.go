package j_credential

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"net/http"
	"time"

	"golang.org/x/net/context"

	"github.com/go-openapi/errors"
	"github.com/go-openapi/runtime"
	cr "github.com/go-openapi/runtime/client"

	strfmt "github.com/go-openapi/strfmt"

	"koding/remoteapi/models"
)

// NewJCredentialOneParams creates a new JCredentialOneParams object
// with the default values initialized.
func NewJCredentialOneParams() *JCredentialOneParams {
	var ()
	return &JCredentialOneParams{

		timeout: cr.DefaultTimeout,
	}
}

// NewJCredentialOneParamsWithTimeout creates a new JCredentialOneParams object
// with the default values initialized, and the ability to set a timeout on a request
func NewJCredentialOneParamsWithTimeout(timeout time.Duration) *JCredentialOneParams {
	var ()
	return &JCredentialOneParams{

		timeout: timeout,
	}
}

// NewJCredentialOneParamsWithContext creates a new JCredentialOneParams object
// with the default values initialized, and the ability to set a context for a request
func NewJCredentialOneParamsWithContext(ctx context.Context) *JCredentialOneParams {
	var ()
	return &JCredentialOneParams{

		Context: ctx,
	}
}

/*JCredentialOneParams contains all the parameters to send to the API endpoint
for the j credential one operation typically these are written to a http.Request
*/
type JCredentialOneParams struct {

	/*Body
	  body of the request

	*/
	Body models.DefaultSelector

	timeout    time.Duration
	Context    context.Context
	HTTPClient *http.Client
}

// WithTimeout adds the timeout to the j credential one params
func (o *JCredentialOneParams) WithTimeout(timeout time.Duration) *JCredentialOneParams {
	o.SetTimeout(timeout)
	return o
}

// SetTimeout adds the timeout to the j credential one params
func (o *JCredentialOneParams) SetTimeout(timeout time.Duration) {
	o.timeout = timeout
}

// WithContext adds the context to the j credential one params
func (o *JCredentialOneParams) WithContext(ctx context.Context) *JCredentialOneParams {
	o.SetContext(ctx)
	return o
}

// SetContext adds the context to the j credential one params
func (o *JCredentialOneParams) SetContext(ctx context.Context) {
	o.Context = ctx
}

// WithBody adds the body to the j credential one params
func (o *JCredentialOneParams) WithBody(body models.DefaultSelector) *JCredentialOneParams {
	o.SetBody(body)
	return o
}

// SetBody adds the body to the j credential one params
func (o *JCredentialOneParams) SetBody(body models.DefaultSelector) {
	o.Body = body
}

// WriteToRequest writes these params to a swagger request
func (o *JCredentialOneParams) WriteToRequest(r runtime.ClientRequest, reg strfmt.Registry) error {

	r.SetTimeout(o.timeout)
	var res []error

	if err := r.SetBodyParam(o.Body); err != nil {
		return err
	}

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}
