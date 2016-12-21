const TimelineBuilder = React.createClass({
  propTypes: {
    timelineEventTypes: React.PropTypes.object
  },

  getInitialState: function () {
    return {
      links: [],
      files: [],
      coverImage: null,
      showLinkForm: false,
      showFileForm: false,
      previousForm: null
    }
  },

  toggleForm: function (type) {
    let previousForm = this.currentForm();

    if (type == 'link') {
      let newState = !this.state.showLinkForm;
      this.setState({showLinkForm: newState, showFileForm: false, previousForm: previousForm});
    } else {
      let newState = !this.state.showFileForm;
      this.setState({showLinkForm: false, showFileForm: newState, previousForm: previousForm});
    }
  },

  currentForm: function () {
    if (this.state.showLinkForm) {
      return 'link'
    } else if (this.state.showFileForm) {
      return 'file'
    } else {
      return null
    }
  },

  hasAttachments: function () {
    return this.state.links.length > 0 || this.state.files.length > 0 || this.state.cover_image != null
  },

  attachments: function () {
    let currentAttachments = [];

    if (this.state.coverImage != null) {
      currentAttachments.push({type: 'cover', title: this.state.coverImage.title});
    }

    this.state.links.forEach(function (link, index) {
      currentAttachments.push({type: 'link', index: index, title: link.title})
    });

    this.state.files.forEach(function (file, index) {
      currentAttachments.push({type: 'file', index: index, title: file.title})
    });

    return currentAttachments;
  },

  addAttachment: function (type, properties) {
    if (type == 'link') {
      this.setState({links: this.state.links.concat([properties])});
      this.toggleForm('link')
    } else if (type == 'file') {
      this.setState({files: this.state.files.concat([properties])});
      this.toggleForm('file')
    } else {
      console.warn('Unhandled attachment type: ', type)
    }
  },

  removeAttachment: function (type, index) {
    if (type == 'cover') {
      this.setState({coverImage: null});
    } else if (type == 'link') {
      let updatedLinks = this.state.links.slice();
      updatedLinks.splice(index, 1);
      this.setState({links: updatedLinks})
    } else if (type == 'file') {
      let updatedFiles = this.state.files.slice();
      let removedFile = updatedFiles.splice(index, 1)[0];
      this.removeFileFromHiddenForm(removedFile.identifier);
      this.setState({files: updatedFiles})
    } else {
      console.warn("Unable to handle instrution to remove attachment of type " + type);
    }
  },

  removeFileFromHiddenForm: function(identifier) {
    $('[name="timeline_event[files][' + identifier + ']"').remove()
  },

  submit: function (event) {
    // TODO: Run presence validations.
    // TODO: Create form and submit it with AJAX.

    // Block the submit from going through.
    event.preventDefault();

    let form = $('.timeline-builder-hidden-form');
    let formData = new FormData(form[0]);

    let description = $('.timeline-builder-textarea').val();

    formData.append('timeline_event[description]', description);

    // Submit form data using AJAX and set a progress handler function.
    $.ajax({
      url: form.attr('action'),
      type: form.attr('method'),

      xhr: function () {
        let myXhr = $.ajaxSettings.xhr();

        // if (myXhr.upload) { // Check if upload property exists.
        //   // For handling the progress of the upload.
        //   myXhr.upload.addEventListener('progress', progressHandlingFunction, false);
        // }

        return myXhr;
      },

      // Ajax events.
      // beforeSend: beforeSendHandler,
      // success: completeHandler,
      // error: errorHandler,

      // Form data
      data: formData,

      // Options to tell jQuery not to process data or worry about content-type.
      cache: false,
      contentType: false,
      processData: false
    });
  },

  render: function () {
    return (
      <div>
        <TimelineBuilderTextArea/>

        { this.hasAttachments() &&
        <TimelineBuilderAttachments attachments={ this.attachments() } removeAttachmentCB={ this.removeAttachment }/>
        }

        <TimelineBuilderAttachmentForm currentForm={ this.currentForm() } previousForm={ this.state.previousForm }
                                       addAttachmentCB={ this.addAttachment }/>
        <TimelineBuilderActionBar formClickedCB={ this.toggleForm } currentForm={ this.currentForm() }
                                  submitCB={ this.submit } timelineEventTypes={ this.props.timelineEventTypes }/>
      </div>
    )
  }
});