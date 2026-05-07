// registration-card/compute.js
//
// Fetches patient data directly from OpenMRS and transforms it
// for use in template.html as {{ compute.<field> }}.
//
// No data-config.json needed — all fetching and transformation is here.

module.exports = {
  compute: async function ({ context, openmrs }) {
    const [patientBundle, relativesBundle] = await Promise.all([
      openmrs.fhir('Patient', { _id: context.patientUuid }),
      openmrs.fhir('RelatedPerson', { patient: context.patientUuid }),
    ]);

    const patient = patientBundle?.entry?.[0]?.resource;
    const relative = relativesBundle?.entry?.[0]?.resource;

    const officialId = patient?.identifier?.find((id) => id.use === 'official');

    const birthDate = patient?.birthDate ?? '';
    const ageYears = birthDate
      ? Math.floor((Date.now() - new Date(birthDate)) / (365.25 * 24 * 60 * 60 * 1000))
      : '';

    const formatDate = (iso) => {
      if (!iso) return '';
      const d = new Date(iso);
      const day = String(d.getUTCDate()).padStart(2, '0');
      const mon = d.toLocaleString('en-GB', { month: 'short', timeZone: 'UTC' });
      return `${day} ${mon} ${d.getUTCFullYear()}`;
    };

    const result = {
      patientName: patient?.name?.[0]?.text ?? '',
      patientId: officialId?.value ?? '',
      birthDate,
      age: ageYears,
      gender: patient?.gender ?? '',
      phone: patient?.telecom?.find((t) => t.system === 'phone')?.value ?? '',
      address: patient?.address?.[0]?.text ?? '',
      photoUrl: `/openmrs/ws/rest/v1/patientImage?patientUuid=${context.patientUuid}`,
      registrationDate: formatDate(officialId?.period?.start ?? patient?.meta?.lastUpdated),
      village: patient?.address?.[0]?.city ?? '',
      tehsil: patient?.address?.[0]?.district ?? '',
      nextOfKinName: relative?.name?.[0]?.text ?? '',
      nextOfKinRelationship: relative?.relationship?.[0]?.text ?? '',
    };
    return result;
  },
};
