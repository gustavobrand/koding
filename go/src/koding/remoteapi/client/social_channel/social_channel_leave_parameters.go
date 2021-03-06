package social_channel

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

// NewSocialChannelLeaveParams creates a new SocialChannelLeaveParams object
// with the default values initialized.
func NewSocialChannelLeaveParams() *SocialChannelLeaveParams {
	var ()
	return &SocialChannelLeaveParams{

		timeout: cr.DefaultTimeout,
	}
}

// NewSocialChannelLeaveParamsWithTimeout creates a new SocialChannelLeaveParams object
// with the default values initialized, and the ability to set a timeout on a request
func NewSocialChannelLeaveParamsWithTimeout(timeout time.Duration) *SocialChannelLeaveParams {
	var ()
	return &SocialChannelLeaveParams{

		timeout: timeout,
	}
}

// NewSocialChannelLeaveParamsWithContext creates a new SocialChannelLeaveParams object
// with the default values initialized, and the ability to set a context for a request
func NewSocialChannelLeaveParamsWithContext(ctx context.Context) *SocialChannelLeaveParams {
	var ()
	return &SocialChannelLeaveParams{

		Context: ctx,
	}
}

/*SocialChannelLeaveParams contains all the parameters to send to the API endpoint
for the social channel leave operation typically these are written to a http.Request
*/
type SocialChannelLeaveParams struct {

	/*Body
	  body of the request

	*/
	Body models.DefaultSelector

	timeout    time.Duration
	Context    context.Context
	HTTPClient *http.Client
}

// WithTimeout adds the timeout to the social channel leave params
func (o *SocialChannelLeaveParams) WithTimeout(timeout time.Duration) *SocialChannelLeaveParams {
	o.SetTimeout(timeout)
	return o
}

// SetTimeout adds the timeout to the social channel leave params
func (o *SocialChannelLeaveParams) SetTimeout(timeout time.Duration) {
	o.timeout = timeout
}

// WithContext adds the context to the social channel leave params
func (o *SocialChannelLeaveParams) WithContext(ctx context.Context) *SocialChannelLeaveParams {
	o.SetContext(ctx)
	return o
}

// SetContext adds the context to the social channel leave params
func (o *SocialChannelLeaveParams) SetContext(ctx context.Context) {
	o.Context = ctx
}

// WithBody adds the body to the social channel leave params
func (o *SocialChannelLeaveParams) WithBody(body models.DefaultSelector) *SocialChannelLeaveParams {
	o.SetBody(body)
	return o
}

// SetBody adds the body to the social channel leave params
func (o *SocialChannelLeaveParams) SetBody(body models.DefaultSelector) {
	o.Body = body
}

// WriteToRequest writes these params to a swagger request
func (o *SocialChannelLeaveParams) WriteToRequest(r runtime.ClientRequest, reg strfmt.Registry) error {

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
