function buildPdfDownload() {
  // The id of the jsreport sample template named "Invoice"
  const templateId = 'rkJTnK2ce';

  const data = {
    amount: 60000,
    number: 99,
    items: [
      {
        name: 'Ice Cream',
        price: 5000
      },
      {
        name: 'Pizza',
        price: 60000
      }
    ]
  };

  return { filename: 'invoice.pdf', templateId, data };
}

context.registerPerspectives({
  binary: {
    PDF: {
      render: buildPdfDownload
    }
  }
});