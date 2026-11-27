module.exports = {
  compute: async function ({ context, data, resolved, ValidationError, fhirPath }) {
    const patientBundle = resolved?.patient;
    const profile       = resolved?.patientProfile;

    const official = fhirPath(patientBundle, "Bundle.entry.first().resource.identifier.where(use = 'official').first().value");
    const fallback = fhirPath(patientBundle, "Bundle.entry.first().resource.identifier.first().value");

    return {
      // Only the primary identifier is exposed; it is the sole value encoded in the barcode.
      patientId:        String(official ?? fallback ?? '').trim(),
      patientName:      fhirPath(patientBundle, "Bundle.entry.first().resource.name.first().text") ?? '',
      birthDate:        fhirPath(patientBundle, "Bundle.entry.first().resource.birthDate") ?? '',
      gender:           fhirPath(patientBundle, "Bundle.entry.first().resource.gender") ?? '',
      village:          fhirPath(patientBundle, "Bundle.entry.first().resource.address.first().city") ?? '',
      registrationDate: profile?.patient?.auditInfo?.dateCreated ?? '',
      photoUrl:         `/openmrs/ws/rest/v1/patientImage?patientUuid=${context.patientUuid}`,
    };
  },
};
