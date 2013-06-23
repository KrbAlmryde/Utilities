from django.db import models
from django.core.validators import *
from django.conf import settings

# _____________________________________________________________________________
# Common classes

class Researcher(models.Model):
  researcher = models.CharField(max_length=64, primary_key=True)
  class Meta:
    db_table = 'Researcher'
  def __unicode__(self):
    return self.researcher

class Location(models.Model):
  location = models.CharField(max_length=64, primary_key=True)
  class Meta:
    db_table = 'Location'
  def __unicode__(self):
    return self.location

class Project(models.Model):
  project = models.CharField(max_length=64, primary_key=True)
  class Meta:
    db_table = 'Project'
    ordering = ['project']
  def __unicode__(self):
    return self.project


# _____________________________________________________________________________
# Participant

SEX_CHOICES = (
  (u'M', u'Male'),
  (u'F', u'Female'),
)

HANDEDNESS_CHOICES = (
  (u'R', u'Right'),
  (u'L', u'Left'),
  (u'A', u'Ambi'),
)

class Cohort(models.Model):
  cohort = models.CharField(max_length=64, primary_key=True)
  class Meta:
    db_table = 'Cohort'
    ordering = ['cohort']
  def __unicode__(self):
    return self.cohort

class Race(models.Model):
  race = models.CharField(max_length=32, primary_key=True)
  class Meta:
    db_table = 'Race'
  def __unicode__(self):
    return self.race

class Participant(models.Model):
  pid = models.CharField(max_length=16, primary_key=True)
  first_name = models.CharField(max_length=64, blank=True)
  middle_name = models.CharField(max_length=64, blank=True)
  last_name = models.CharField(max_length=64, blank=True)
  date_of_birth = models.DateField(null=True, blank=True)
  date_of_death = models.DateField(null=True, blank=True)
  sex = models.CharField(max_length=1, choices=SEX_CHOICES, blank=True)
  handedness = models.CharField(max_length=1, choices=HANDEDNESS_CHOICES, blank=True)
  ssn = models.CharField(max_length=16, blank=True, verbose_name="SSN")
  mrn = models.CharField(max_length=16, blank=True, verbose_name="MRN")
  intake_date = models.DateField(null=True, blank=True)
  project = models.ForeignKey(Project, db_column='project')
  cohort = models.ForeignKey(Cohort, db_column='cohort', null=True, blank=True)
  onset_date = models.DateField(null=True, blank=True)
  onset_time = models.TimeField(null=True, blank=True)
  photo = models.ImageField(upload_to="photos", null=True, blank=True)

  education = models.IntegerField(validators=[MinValueValidator(-1), MaxValueValidator(20)], null=True, blank=True)
  occupation = models.CharField(max_length=128, blank=True)
  spouse_occupation = models.CharField(max_length=128, blank=True)
  hispanic_or_latino = models.NullBooleanField()
  race = models.ManyToManyField(Race, blank=True)

  primary_language = models.CharField(max_length=64, blank=True)
  first_language = models.CharField(max_length=64, blank=True)
  other_languages = models.CharField(max_length=256, blank=True)
  where_grew_up = models.CharField(max_length=64, blank=True)
  spelling_ability = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)], null=True, blank=True)
  reading_ability = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)], null=True, blank=True)
  dyslexia_history = models.NullBooleanField()
  speech_language_history = models.NullBooleanField()

  special_education_history = models.NullBooleanField()
  handedness_in_family = models.CharField(max_length=256, blank=True)
  glasses = models.NullBooleanField()
  uncorrected_vision_problems = models.NullBooleanField()
  hearing_loss = models.NullBooleanField()
  hearing_aid_left = models.NullBooleanField()
  hearing_aid_right = models.NullBooleanField()
  medications = models.CharField(max_length=256, blank=True)
  head_injury = models.NullBooleanField()
  stroke = models.NullBooleanField()
  aphasia = models.NullBooleanField()
  brain_surgery = models.NullBooleanField()
  communication_disorder = models.NullBooleanField()
  memory = models.NullBooleanField()
  depression = models.NullBooleanField()
  psychiatric = models.NullBooleanField()
  alcohol_abuse = models.NullBooleanField()
  substance_abuse = models.NullBooleanField()
  dementia = models.NullBooleanField()
  parkinsons = models.NullBooleanField()
  epilepsy_seizure = models.NullBooleanField()
  other_neurological = models.NullBooleanField()
  other_major_illness = models.NullBooleanField()
  general_health = models.CharField(max_length=128, blank=True)
  psychoactive_meds = models.NullBooleanField()
  history_notes = models.TextField(max_length=1024, blank=True)

  notes = models.TextField(max_length=4096, blank=True)

  class Meta:
    db_table = 'Participant'
    ordering = ['pid']

  def __unicode__(self):
    return u'%s %s %s %s (%s, %s)' % (self.pid, self.first_name, self.middle_name, self.last_name, self.cohort, self.project)

  def given_names(self):
    return u'%s %s' % (self.first_name, self.middle_name)

  def get_photo_html(self):
    return '<img src="%s%s" />' % (settings.MEDIA_URL, self.photo, )
  get_photo_html.allow_tags = True

  def get_photo_filename(self):
    return '%s%s' % (settings.MEDIA_ROOT, self.photo, )

  def get_photo_url(self):
    return '%s%s' % (settings.MEDIA_URL, self.photo, )


# _____________________________________________________________________________
# Diagnosis

class Syndrome(models.Model):
  syndrome = models.CharField(max_length=64, primary_key=True)
  class Meta:
    db_table = 'Syndrome'
    ordering = ['syndrome']
  def __unicode__(self):
    return self.syndrome

class Diagnosis(models.Model):
  diagnosis_id = models.AutoField(primary_key=True)
  pid = models.ForeignKey(Participant, db_column='pid')
  diagnosis_date = models.DateField()
  diag = models.ForeignKey(Syndrome, db_column='diag', verbose_name="Diagnosis", related_name='+')
  notes = models.TextField(max_length=1024, blank=True)

  class Meta:
    db_table = 'Diagnosis'
    verbose_name_plural = "Diagnoses"

  def __unicode__(self):
    return u'%s %s' % (self.diagnosis_date, self.diag)


# _____________________________________________________________________________
# Address

class Address(models.Model):
  address_id = models.AutoField(primary_key=True)
  pid = models.ForeignKey(Participant, db_column='pid')
  name_if_not_self = models.CharField(max_length=128, blank=True)
  relation_if_not_self = models.CharField(max_length=16, blank=True)
  address1 = models.CharField(max_length=128, blank=True)
  address2 = models.CharField(max_length=128, blank=True)
  city = models.CharField(max_length=32, blank=True)
  state = models.CharField(max_length=16, blank=True)
  zip_code = models.CharField(max_length=16, blank=True)
  phone1 = models.CharField(max_length=32, blank=True)
  phone2 = models.CharField(max_length=32, blank=True)
  email = models.CharField(max_length=64, blank=True)
  notes = models.TextField(max_length=1024, blank=True)

  class Meta:
    db_table = 'Address'
    verbose_name_plural = "Addresses"

  def __unicode__(self):
    return u'%s %s %s' % (self.name_if_not_self, self.relation_if_not_self, self.address1)


# _____________________________________________________________________________
# Consent

class ConsentFormDate(models.Model):
  consent_form_date = models.DateField(primary_key=True)
  class Meta:
    db_table = 'ConsentFormDate'
  def __unicode__(self):
    return unicode(self.consent_form_date)

class Consent(models.Model):
  consent_id = models.AutoField(primary_key=True)
  pid = models.ForeignKey(Participant, db_column='pid')
  consent_date = models.DateField()
  project = models.ForeignKey(Project, db_column='project')
  form_date = models.ForeignKey(ConsentFormDate, db_column='form_date', null=True, blank=True)
  consenter = models.ForeignKey(Researcher, db_column='consenter', null=True, blank=True)
  assessment = models.BooleanField()
  mri = models.BooleanField()
  fmri = models.BooleanField()
  follow_up = models.BooleanField()
  auth_rep = models.CharField(max_length=128, blank=True)
  auth_rep_relation = models.CharField(max_length=16, blank=True)

  mri_screen = models.BooleanField()
  safe_to_scan = models.NullBooleanField()
  mri_screen_details = models.CharField(max_length=1024, blank=True)

  audio_video = models.BooleanField()
  phi = models.BooleanField()
  med_records = models.BooleanField()
  share_name = models.BooleanField()

  notes = models.TextField(max_length=1024, blank=True)

  class Meta:
    db_table = 'Consent'

  def __unicode__(self):
    return unicode(self.consent_date)


# _____________________________________________________________________________
# Data

class DataType(models.Model):
  data_type = models.CharField(max_length=64, primary_key=True)
  class Meta:
    db_table = 'DataType'
  def __unicode__(self):
    return self.data_type

class DataStatus(models.Model):
  data_status = models.CharField(max_length=64, primary_key=True)
  class Meta:
    db_table = 'DataStatus'
    verbose_name_plural = "Data statuses"
  def __unicode__(self):
    return self.data_status

class Data(models.Model):
  data_id = models.AutoField(primary_key=True)
  pid = models.ForeignKey(Participant, db_column='pid')
  date_acquired = models.DateField()
  time_acquired = models.TimeField(null=True, blank=True)
  data_type = models.ForeignKey(DataType, db_column='data_type')
  status = models.ForeignKey(DataStatus, db_column='status', default=1)
  acquired_by = models.ForeignKey(Researcher, db_column='acquired_by', null=True, blank=True, related_name='acquired_by')
  acquired_by_2 = models.ForeignKey(Researcher, db_column='acquired_by_2', null=True, blank=True, related_name='acquired_by2')
  location = models.ForeignKey(Location, db_column='location', null=True, blank=True)
  project = models.ForeignKey(Project, db_column='project', null=True, blank=True)
  participant_pay = models.DecimalField(max_digits=5, decimal_places=2, default=0)
  notes = models.TextField(max_length=1024, blank=True)
  
  class Meta:
    db_table = 'Data'
    verbose_name_plural = "Data"
    ordering = ['date_acquired']

  def __unicode__(self):
    return u'%s %s %s' % (self.data_id, self.date_acquired, self.data_type)


# _____________________________________________________________________________
# ScanningSession

class Scanner(models.Model):
  scanner = models.CharField(max_length=64, primary_key=True)
  class Meta:
    db_table = 'Scanner'
  def __unicode__(self):
    return self.scanner

# ScanningSession
class ScanningSession(Data):
  scanner = models.ForeignKey(Scanner, db_column='scanner', null=True, blank=True)
  scanning_cost = models.DecimalField(max_digits=5, decimal_places=2, default=0)
  anatomical = models.ForeignKey('Scan', null=True, blank=True)

  class Meta:
    db_table = 'ScanningSession'

  def __unicode__(self):
    return u'%s %s' % (self.date_acquired, self.data_type)


# _____________________________________________________________________________
# Scan

class ScanType(models.Model):
  scan_type = models.CharField(max_length=32, primary_key=True)
  class Meta:
    db_table = 'ScanType'
  def __unicode__(self):
    return self.scan_type

class FmriStudy(models.Model):
  fmri_study = models.CharField(max_length=32, primary_key=True)
  class Meta:
    db_table = 'FmriStudy'
    verbose_name_plural = "Fmri studies"
  def __unicode__(self):
    return self.fmri_study

class Paradigm(models.Model):
  paradigm = models.CharField(max_length=32, primary_key=True)
  class Meta:
    db_table = 'Paradigm'
  def __unicode__(self):
    return self.paradigm

class ScanStatus(models.Model):
  scan_status = models.CharField(max_length=32, primary_key=True)
  class Meta:
    db_table = 'ScanStatus'
    verbose_name_plural = "Scan statuses"
  def __unicode__(self):
    return self.scan_status

class ScanQuality(models.Model):
  scan_quality = models.CharField(max_length=32, primary_key=True)
  class Meta:
    db_table = 'ScanQuality'
    verbose_name_plural = "Scan qualities"
  def __unicode__(self):
    return self.scan_quality

class Scan(models.Model):
  scan_id = models.AutoField(primary_key=True)
  scanning_session = models.ForeignKey(ScanningSession)
  scan_type = models.ForeignKey(ScanType, db_column='scan_type')
  acq_order = models.IntegerField()
  image_fname = models.CharField(max_length=256, blank=True)
  status = models.ForeignKey(ScanStatus, db_column='status', default='Acquired')
  quality = models.ForeignKey(ScanQuality, db_column='quality', default='Not checked')
  fmri_study = models.ForeignKey(FmriStudy, db_column='fmri_study', null=True, blank=True)
  run = models.IntegerField(null=True, blank=True)
  n_vols = models.IntegerField(null=True, blank=True)
  n_discard = models.IntegerField(null=True, blank=True)
  paradigm = models.ForeignKey(Paradigm, db_column='paradigm', null=True, blank=True)
  version = models.CharField(max_length=8, blank=True)
  behav_raw = models.CharField(max_length=256, blank=True)
  behav_proc = models.CharField(max_length=256, blank=True)
  notes = models.TextField(max_length=1024, blank=True)
  segment = models.BooleanField()
  exclude_ics = models.CharField(max_length=256, blank=True, verbose_name="Exclude ICs")
  exclude_vols = models.CharField(max_length=256, blank=True)
  manual_coreg = models.CharField(max_length=128, blank=True)

  class Meta:
    db_table = 'Scan'
    ordering = ['scanning_session', 'acq_order']

  def __unicode__(self):
    return u'%s %s %s <%s>' % (unicode(self.scanning_session.pid), unicode(self.scanning_session.date_acquired), unicode(self.scan_type), unicode(self.scan_id))


# _____________________________________________________________________________
# Note

class Note(Data):

  class Meta:
    db_table = 'Note'

  def __unicode__(self):
    return u'%s %s' % (self.date_acquired, self.data_type)


# _____________________________________________________________________________
# LangEval

class SWCResponse(models.Model):
  swc_response = models.CharField(max_length=32, primary_key=True)
  class Meta:
    db_table = 'SWCResponse'
  def __unicode__(self):
    return self.swc_response

class SCResponse(models.Model):
  sc_response = models.CharField(max_length=32, primary_key=True)
  class Meta:
    db_table = 'SCResponse'
  def __unicode__(self):
    return self.sc_response

class LangEval(Data):
  conversation = models.IntegerField("Conversation", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  conversation_response = models.TextField("Response", max_length=4096, blank=True)
  conversation_notes = models.TextField(max_length=1024, blank=True)

  automatic_speech_1 = models.IntegerField("1. count to 21", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  automatic_speech_1_response = models.TextField("Response", max_length=1024, blank=True)
  automatic_speech_2 = models.IntegerField("2. days of the week", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  automatic_speech_2_response = models.TextField("Response", max_length=1024, blank=True)
  automatic_speech_3 = models.IntegerField("3. happy birthday", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  automatic_speech_3_response = models.TextField("Response", max_length=1024, blank=True)
  automatic_speech_notes = models.TextField(max_length=1024, blank=True)

  oral_agility_1 = models.IntegerField("1. tongue to alternate corners of mouth", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  oral_agility_2 = models.IntegerField("2. purse lips and smile", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  oral_agility_notes = models.TextField(max_length=1024, blank=True)

  articulatory_agility_1 = models.IntegerField("1. aaaah", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  articulatory_agility_1_response = models.TextField("Response", max_length=1024, blank=True)
  articulatory_agility_2 = models.IntegerField("2. pa pa pa", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  articulatory_agility_2_response = models.TextField("Response", max_length=1024, blank=True)
  articulatory_agility_3 = models.IntegerField("3. ta ta ta", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  articulatory_agility_3_response = models.TextField("Response", max_length=1024, blank=True)
  articulatory_agility_4 = models.IntegerField("4. ka ka ka", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  articulatory_agility_4_response = models.TextField("Response", max_length=1024, blank=True)
  articulatory_agility_5 = models.IntegerField("5. pataka", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  articulatory_agility_5_response = models.TextField("Response", max_length=1024, blank=True)
  articulatory_agility_6 = models.IntegerField("6. buttercup", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  articulatory_agility_6_response = models.TextField("Response", max_length=1024, blank=True)
  articulatory_agility_7 = models.IntegerField("7. catastrophe", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  articulatory_agility_7_response = models.TextField("Response", max_length=1024, blank=True)
  articulatory_agility_8 = models.IntegerField("8. criticism", validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  articulatory_agility_8_response = models.TextField("Response", max_length=1024, blank=True)
  articulatory_agility_aos = models.IntegerField("Apraxia of speech", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True, help_text="0 = none, 1-2 = mild, 3 = moderate, 4-5 = severe")
  articulatory_agility_dysarthria = models.IntegerField("Dysarthria", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True, help_text="0 = none, 1-2 = mild, 3 = moderate, 4-5 = severe")
  articulatory_agility_notes = models.TextField(max_length=1024, blank=True)

  connected_speech_1 = models.IntegerField(validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  connected_speech_1_response = models.TextField("Response", max_length=4096, blank=True)
  connected_speech_2 = models.IntegerField(validators=[MinValueValidator(-1), MaxValueValidator(1)], null=True, blank=True)
  connected_speech_2_response = models.TextField("Response", max_length=4096, blank=True)
  connected_speech_rate = models.IntegerField("1. Rate", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True)
  connected_speech_mlu = models.IntegerField("2. MLU", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True)
  connected_speech_phonology = models.IntegerField("3. Phonology", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True)
  connected_speech_morphosyntax = models.IntegerField("4. Morphosyntax", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True)
  connected_speech_word_finding = models.IntegerField("5. Word finding", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True)
  connected_speech_relevance = models.IntegerField("6. Relevance", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True)
  connected_speech_notes = models.TextField(max_length=1024, blank=True)

  picture_naming_1 = models.IntegerField("1. banana", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_1_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_1_delayed = models.BooleanField("D")
  picture_naming_1_self_corrected = models.BooleanField("SC")
  picture_naming_2 = models.IntegerField("2. pencil", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_2_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_2_delayed = models.BooleanField("D")
  picture_naming_2_self_corrected = models.BooleanField("SC")
  picture_naming_3 = models.IntegerField("3. truck", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_3_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_3_delayed = models.BooleanField("D")
  picture_naming_3_self_corrected = models.BooleanField("SC")
  picture_naming_4 = models.IntegerField("4. candle", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_4_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_4_delayed = models.BooleanField("D")
  picture_naming_4_self_corrected = models.BooleanField("SC")
  picture_naming_5 = models.IntegerField("5. glove", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_5_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_5_delayed = models.BooleanField("D")
  picture_naming_5_self_corrected = models.BooleanField("SC")
  picture_naming_6 = models.IntegerField("6. screw", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_6_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_6_delayed = models.BooleanField("D")
  picture_naming_6_self_corrected = models.BooleanField("SC")
  picture_naming_7 = models.IntegerField("7. kangaroo", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_7_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_7_delayed = models.BooleanField("D")
  picture_naming_7_self_corrected = models.BooleanField("SC")
  picture_naming_8 = models.IntegerField("8. bicycle", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_8_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_8_delayed = models.BooleanField("D")
  picture_naming_8_self_corrected = models.BooleanField("SC")
  picture_naming_9 = models.IntegerField("9. windmill", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_9_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_9_delayed = models.BooleanField("D")
  picture_naming_9_self_corrected = models.BooleanField("SC")
  picture_naming_10 = models.IntegerField("10. rhinoceros", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_10_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_10_delayed = models.BooleanField("D")
  picture_naming_10_self_corrected = models.BooleanField("SC")
  picture_naming_11 = models.IntegerField("11. caterpillar", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_11_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_11_delayed = models.BooleanField("D")
  picture_naming_11_self_corrected = models.BooleanField("SC")
  picture_naming_12 = models.IntegerField("12. helicopter", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_12_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_12_delayed = models.BooleanField("D")
  picture_naming_12_self_corrected = models.BooleanField("SC")
  picture_naming_notes = models.TextField(max_length=1024, blank=True)

  picture_naming_written_1 = models.IntegerField("1. car", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_written_1_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_written_1_delayed = models.BooleanField("D")
  picture_naming_written_1_self_corrected = models.BooleanField("SC")
  picture_naming_written_2 = models.IntegerField("2. broom", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_written_2_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_written_2_delayed = models.BooleanField("D")
  picture_naming_written_2_self_corrected = models.BooleanField("SC")
  picture_naming_written_3 = models.IntegerField("3. guitar", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_written_3_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_written_3_delayed = models.BooleanField("D")
  picture_naming_written_3_self_corrected = models.BooleanField("SC")
  picture_naming_written_4 = models.IntegerField("4. giraffe", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  picture_naming_written_4_response = models.CharField("Response", max_length=128, blank=True)
  picture_naming_written_4_delayed = models.BooleanField("D")
  picture_naming_written_4_self_corrected = models.BooleanField("SC")
  picture_naming_written_notes = models.TextField(max_length=1024, blank=True)

  single_word_comprehension_1 = models.IntegerField("1. lion", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_1_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_1_delayed = models.BooleanField("D")
  single_word_comprehension_1_self_corrected = models.BooleanField("SC")
  single_word_comprehension_1_repeated = models.BooleanField("R")
  single_word_comprehension_2 = models.IntegerField("2. pear", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_2_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_2_delayed = models.BooleanField("D")
  single_word_comprehension_2_self_corrected = models.BooleanField("SC")
  single_word_comprehension_2_repeated = models.BooleanField("R")
  single_word_comprehension_3 = models.IntegerField("3. apple", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_3_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_3_delayed = models.BooleanField("D")
  single_word_comprehension_3_self_corrected = models.BooleanField("SC")
  single_word_comprehension_3_repeated = models.BooleanField("R")
  single_word_comprehension_4 = models.IntegerField("4. bear", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_4_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_4_delayed = models.BooleanField("D")
  single_word_comprehension_4_self_corrected = models.BooleanField("SC")
  single_word_comprehension_4_repeated = models.BooleanField("R")
  single_word_comprehension_5 = models.IntegerField("5. box", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_5_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_5_delayed = models.BooleanField("D")
  single_word_comprehension_5_self_corrected = models.BooleanField("SC")
  single_word_comprehension_5_repeated = models.BooleanField("R")
  single_word_comprehension_6 = models.IntegerField("6. raccoon", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_6_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_6_delayed = models.BooleanField("D")
  single_word_comprehension_6_self_corrected = models.BooleanField("SC")
  single_word_comprehension_6_repeated = models.BooleanField("R")
  single_word_comprehension_7 = models.IntegerField("7. basket", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_7_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_7_delayed = models.BooleanField("D")
  single_word_comprehension_7_self_corrected = models.BooleanField("SC")
  single_word_comprehension_7_repeated = models.BooleanField("R")
  single_word_comprehension_8 = models.IntegerField("8. fox", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_8_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_8_delayed = models.BooleanField("D")
  single_word_comprehension_8_self_corrected = models.BooleanField("SC")
  single_word_comprehension_8_repeated = models.BooleanField("R")
  single_word_comprehension_9 = models.IntegerField("9. cat", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_9_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_9_delayed = models.BooleanField("D")
  single_word_comprehension_9_self_corrected = models.BooleanField("SC")
  single_word_comprehension_9_repeated = models.BooleanField("R")
  single_word_comprehension_10 = models.IntegerField("10. house", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_10_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_10_delayed = models.BooleanField("D")
  single_word_comprehension_10_self_corrected = models.BooleanField("SC")
  single_word_comprehension_10_repeated = models.BooleanField("R")
  single_word_comprehension_11 = models.IntegerField("11. mouse", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_11_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_11_delayed = models.BooleanField("D")
  single_word_comprehension_11_self_corrected = models.BooleanField("SC")
  single_word_comprehension_11_repeated = models.BooleanField("R")
  single_word_comprehension_12 = models.IntegerField("12. church", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_12_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_12_delayed = models.BooleanField("D")
  single_word_comprehension_12_self_corrected = models.BooleanField("SC")
  single_word_comprehension_12_repeated = models.BooleanField("R")
  single_word_comprehension_13 = models.IntegerField("13. artichoke", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_13_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_13_delayed = models.BooleanField("D")
  single_word_comprehension_13_self_corrected = models.BooleanField("SC")
  single_word_comprehension_13_repeated = models.BooleanField("R")
  single_word_comprehension_14 = models.IntegerField("14. asparagus", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_14_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_14_delayed = models.BooleanField("D")
  single_word_comprehension_14_self_corrected = models.BooleanField("SC")
  single_word_comprehension_14_repeated = models.BooleanField("R")
  single_word_comprehension_15 = models.IntegerField("15. celery", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_15_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_15_delayed = models.BooleanField("D")
  single_word_comprehension_15_self_corrected = models.BooleanField("SC")
  single_word_comprehension_15_repeated = models.BooleanField("R")
  single_word_comprehension_16 = models.IntegerField("16. lettuce", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_16_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_16_delayed = models.BooleanField("D")
  single_word_comprehension_16_self_corrected = models.BooleanField("SC")
  single_word_comprehension_16_repeated = models.BooleanField("R")
  single_word_comprehension_notes = models.TextField(max_length=1024, blank=True)

  single_word_comprehension_reading_1 = models.IntegerField("1. pants", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_reading_1_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_reading_1_delayed = models.BooleanField("D")
  single_word_comprehension_reading_1_self_corrected = models.BooleanField("SC")
  single_word_comprehension_reading_1_repeated = models.BooleanField("R")
  single_word_comprehension_reading_2 = models.IntegerField("2. goat", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_reading_2_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_reading_2_delayed = models.BooleanField("D")
  single_word_comprehension_reading_2_self_corrected = models.BooleanField("SC")
  single_word_comprehension_reading_2_repeated = models.BooleanField("R")
  single_word_comprehension_reading_3 = models.IntegerField("3. sheep", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_reading_3_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_reading_3_delayed = models.BooleanField("D")
  single_word_comprehension_reading_3_self_corrected = models.BooleanField("SC")
  single_word_comprehension_reading_3_repeated = models.BooleanField("R")
  single_word_comprehension_reading_4 = models.IntegerField("4. coat", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  single_word_comprehension_reading_4_response = models.ForeignKey(SWCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  single_word_comprehension_reading_4_delayed = models.BooleanField("D")
  single_word_comprehension_reading_4_self_corrected = models.BooleanField("SC")
  single_word_comprehension_reading_4_repeated = models.BooleanField("R")
  single_word_comprehension_reading_notes = models.TextField(max_length=1024, blank=True)

  sentence_comprehension_1 = models.IntegerField("1. The boy is pushing the girl. (sa)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_1_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_1_delayed = models.BooleanField("D")
  sentence_comprehension_1_self_corrected = models.BooleanField("SC")
  sentence_comprehension_1_repeated = models.BooleanField("R")
  sentence_comprehension_2 = models.IntegerField("2. The girl is pulling the boy. (sa)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_2_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_2_delayed = models.BooleanField("D")
  sentence_comprehension_2_self_corrected = models.BooleanField("SC")
  sentence_comprehension_2_repeated = models.BooleanField("R")
  sentence_comprehension_3 = models.IntegerField("3. The boy is kissed by the girl. (sp)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_3_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_3_delayed = models.BooleanField("D")
  sentence_comprehension_3_self_corrected = models.BooleanField("SC")
  sentence_comprehension_3_repeated = models.BooleanField("R")
  sentence_comprehension_4 = models.IntegerField("4. The girl is hugging the boy. (sa)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_4_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_4_delayed = models.BooleanField("D")
  sentence_comprehension_4_self_corrected = models.BooleanField("SC")
  sentence_comprehension_4_repeated = models.BooleanField("R")
  sentence_comprehension_5 = models.IntegerField("5. The girl is washed by the boy. (sp)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_5_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_5_delayed = models.BooleanField("D")
  sentence_comprehension_5_self_corrected = models.BooleanField("SC")
  sentence_comprehension_5_repeated = models.BooleanField("R")
  sentence_comprehension_6 = models.IntegerField("6. The boy is chased by the girl. (sp)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_6_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_6_delayed = models.BooleanField("D")
  sentence_comprehension_6_self_corrected = models.BooleanField("SC")
  sentence_comprehension_6_repeated = models.BooleanField("R")
  sentence_comprehension_7 = models.IntegerField("7. The boy who is red is pushing the girl. (le)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_7_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_7_delayed = models.BooleanField("D")
  sentence_comprehension_7_self_corrected = models.BooleanField("SC")
  sentence_comprehension_7_repeated = models.BooleanField("R")
  sentence_comprehension_8 = models.IntegerField("8. The girl who is washing the boy is blue. (lm)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_8_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_8_delayed = models.BooleanField("D")
  sentence_comprehension_8_self_corrected = models.BooleanField("SC")
  sentence_comprehension_8_repeated = models.BooleanField("R")
  sentence_comprehension_9 = models.IntegerField("9. The girl who is kissed by the boy is blue. (ld)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_9_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_9_delayed = models.BooleanField("D")
  sentence_comprehension_9_self_corrected = models.BooleanField("SC")
  sentence_comprehension_9_repeated = models.BooleanField("R")
  sentence_comprehension_10 = models.IntegerField("10. The girl who is green is hugging the boy. (le)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_10_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_10_delayed = models.BooleanField("D")
  sentence_comprehension_10_self_corrected = models.BooleanField("SC")
  sentence_comprehension_10_repeated = models.BooleanField("R")
  sentence_comprehension_11 = models.IntegerField("11. The boy who is kicked by the girl is red. (ld)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_11_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_11_delayed = models.BooleanField("D")
  sentence_comprehension_11_self_corrected = models.BooleanField("SC")
  sentence_comprehension_11_repeated = models.BooleanField("R")
  sentence_comprehension_12 = models.IntegerField("12. The boy who is chasing the girl is green. (lm)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_12_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_12_delayed = models.BooleanField("D")
  sentence_comprehension_12_self_corrected = models.BooleanField("SC")
  sentence_comprehension_12_repeated = models.BooleanField("R")
  sentence_comprehension_notes = models.TextField(max_length=1024, blank=True)

  sentence_comprehension_reading_1 = models.IntegerField("1. The boy is hugging the girl. (sa)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_reading_1_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_reading_1_delayed = models.BooleanField("D")
  sentence_comprehension_reading_1_self_corrected = models.BooleanField("SC")
  sentence_comprehension_reading_1_repeated = models.BooleanField("R")
  sentence_comprehension_reading_2 = models.IntegerField("2. The girl is kicked by the boy. (sp)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_reading_2_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_reading_2_delayed = models.BooleanField("D")
  sentence_comprehension_reading_2_self_corrected = models.BooleanField("SC")
  sentence_comprehension_reading_2_repeated = models.BooleanField("R")
  sentence_comprehension_reading_3 = models.IntegerField("3. The girl who is pulling the boy is green. (lm)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_reading_3_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_reading_3_delayed = models.BooleanField("D")
  sentence_comprehension_reading_3_self_corrected = models.BooleanField("SC")
  sentence_comprehension_reading_3_repeated = models.BooleanField("R")
  sentence_comprehension_reading_4 = models.IntegerField("4. The boy who is pushed by the girl is blue. (ld)", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  sentence_comprehension_reading_4_response = models.ForeignKey(SCResponse, verbose_name="Response", null=True, blank=True, related_name='+')
  sentence_comprehension_reading_4_delayed = models.BooleanField("D")
  sentence_comprehension_reading_4_self_corrected = models.BooleanField("SC")
  sentence_comprehension_reading_4_repeated = models.BooleanField("R")
  sentence_comprehension_reading_notes = models.TextField(max_length=1024, blank=True)

  repetition_words_1 = models.IntegerField("1. dog", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_words_1_response = models.CharField("Response", max_length=128, blank=True)
  repetition_words_1_delayed = models.BooleanField("D")
  repetition_words_1_self_corrected = models.BooleanField("SC")
  repetition_words_1_repeated = models.BooleanField("R")
  repetition_words_2 = models.IntegerField("2. window", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_words_2_response = models.CharField("Response", max_length=128, blank=True)
  repetition_words_2_delayed = models.BooleanField("D")
  repetition_words_2_self_corrected = models.BooleanField("SC")
  repetition_words_2_repeated = models.BooleanField("R")
  repetition_words_3 = models.IntegerField("3. religion", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_words_3_response = models.CharField("Response", max_length=128, blank=True)
  repetition_words_3_delayed = models.BooleanField("D")
  repetition_words_3_self_corrected = models.BooleanField("SC")
  repetition_words_3_repeated = models.BooleanField("R")
  repetition_words_4 = models.IntegerField("4. secretary", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_words_4_response = models.CharField("Response", max_length=128, blank=True)
  repetition_words_4_delayed = models.BooleanField("D")
  repetition_words_4_self_corrected = models.BooleanField("SC")
  repetition_words_4_repeated = models.BooleanField("R")
  repetition_words_5 = models.IntegerField("5. lavender", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_words_5_response = models.CharField("Response", max_length=128, blank=True)
  repetition_words_5_delayed = models.BooleanField("D")
  repetition_words_5_self_corrected = models.BooleanField("SC")
  repetition_words_5_repeated = models.BooleanField("R")
  repetition_words_6 = models.IntegerField("6. metaphor", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_words_6_response = models.CharField("Response", max_length=128, blank=True)
  repetition_words_6_delayed = models.BooleanField("D")
  repetition_words_6_self_corrected = models.BooleanField("SC")
  repetition_words_6_repeated = models.BooleanField("R")
  repetition_words_7 = models.IntegerField("7. unmanageable", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_words_7_response = models.CharField("Response", max_length=128, blank=True)
  repetition_words_7_delayed = models.BooleanField("D")
  repetition_words_7_self_corrected = models.BooleanField("SC")
  repetition_words_7_repeated = models.BooleanField("R")
  repetition_words_8 = models.IntegerField("8. decertified", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_words_8_response = models.CharField("Response", max_length=128, blank=True)
  repetition_words_8_delayed = models.BooleanField("D")
  repetition_words_8_self_corrected = models.BooleanField("SC")
  repetition_words_8_repeated = models.BooleanField("R")
  repetition_words_9 = models.IntegerField("9. contrasting", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_words_9_response = models.CharField("Response", max_length=128, blank=True)
  repetition_words_9_delayed = models.BooleanField("D")
  repetition_words_9_self_corrected = models.BooleanField("SC")
  repetition_words_9_repeated = models.BooleanField("R")
  repetition_words_10 = models.IntegerField("10. 29", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_words_10_response = models.CharField("Response", max_length=128, blank=True)
  repetition_words_10_delayed = models.BooleanField("D")
  repetition_words_10_self_corrected = models.BooleanField("SC")
  repetition_words_10_repeated = models.BooleanField("R")
  repetition_words_11 = models.IntegerField("11. 452", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_words_11_response = models.CharField("Response", max_length=128, blank=True)
  repetition_words_11_delayed = models.BooleanField("D")
  repetition_words_11_self_corrected = models.BooleanField("SC")
  repetition_words_11_repeated = models.BooleanField("R")
  repetition_words_notes = models.TextField(max_length=1024, blank=True)

  repetition_sentences_1 = models.DecimalField("1. All cows eat grass. (/4)", validators=[MinValueValidator(-1), MaxValueValidator(4)], null=True, blank=True, max_digits=3, decimal_places=1)
  repetition_sentences_1_response = models.CharField("Response", max_length=1024, blank=True)
  repetition_sentences_1_delayed = models.BooleanField("D")
  repetition_sentences_1_self_corrected = models.BooleanField("SC")
  repetition_sentences_1_repeated = models.BooleanField("R")
  repetition_sentences_2 = models.DecimalField("2. They wanted to hear the girl sing. (/7)", validators=[MinValueValidator(-1), MaxValueValidator(7)], null=True, blank=True, max_digits=3, decimal_places=1)
  repetition_sentences_2_response = models.CharField("Response", max_length=1024, blank=True)
  repetition_sentences_2_delayed = models.BooleanField("D")
  repetition_sentences_2_self_corrected = models.BooleanField("SC")
  repetition_sentences_2_repeated = models.BooleanField("R")
  repetition_sentences_3 = models.DecimalField("3. We walked down to the beach and looked at the ocean. (/11)", validators=[MinValueValidator(-1), MaxValueValidator(11)], null=True, blank=True, max_digits=3, decimal_places=1)
  repetition_sentences_3_response = models.CharField("Response", max_length=1024, blank=True)
  repetition_sentences_3_delayed = models.BooleanField("D")
  repetition_sentences_3_self_corrected = models.BooleanField("SC")
  repetition_sentences_3_repeated = models.BooleanField("R")
  repetition_sentences_4 = models.DecimalField("4. The pastry chef was elated. (/5)", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True, max_digits=3, decimal_places=1)
  repetition_sentences_4_response = models.CharField("Response", max_length=1024, blank=True)
  repetition_sentences_4_delayed = models.BooleanField("D")
  repetition_sentences_4_self_corrected = models.BooleanField("SC")
  repetition_sentences_4_repeated = models.BooleanField("R")
  repetition_sentences_5 = models.DecimalField("5. Teen girls apply cosmetics daily. (/5)", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True, max_digits=3, decimal_places=1)
  repetition_sentences_5_response = models.CharField("Response", max_length=1024, blank=True)
  repetition_sentences_5_delayed = models.BooleanField("D")
  repetition_sentences_5_self_corrected = models.BooleanField("SC")
  repetition_sentences_5_repeated = models.BooleanField("R")
  repetition_sentences_6 = models.DecimalField("6. She might have been there when we were. (/8)", validators=[MinValueValidator(-1), MaxValueValidator(8)], null=True, blank=True, max_digits=3, decimal_places=1)
  repetition_sentences_6_response = models.CharField("Response", max_length=1024, blank=True)
  repetition_sentences_6_delayed = models.BooleanField("D")
  repetition_sentences_6_self_corrected = models.BooleanField("SC")
  repetition_sentences_6_repeated = models.BooleanField("R")
  repetition_sentences_7 = models.DecimalField("7. No ifs, ands or buts. (/5)", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True, max_digits=3, decimal_places=1)
  repetition_sentences_7_response = models.CharField("Response", max_length=1024, blank=True)
  repetition_sentences_7_delayed = models.BooleanField("D")
  repetition_sentences_7_self_corrected = models.BooleanField("SC")
  repetition_sentences_7_repeated = models.BooleanField("R")
  repetition_sentences_notes = models.TextField(max_length=1024, blank=True)

  repetition_pseudowords_1 = models.IntegerField("1. blik", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_pseudowords_1_response = models.CharField("Response", max_length=128, blank=True)
  repetition_pseudowords_1_delayed = models.BooleanField("D")
  repetition_pseudowords_1_self_corrected = models.BooleanField("SC")
  repetition_pseudowords_1_repeated = models.BooleanField("R")
  repetition_pseudowords_2 = models.IntegerField("2. tamp", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_pseudowords_2_response = models.CharField("Response", max_length=128, blank=True)
  repetition_pseudowords_2_delayed = models.BooleanField("D")
  repetition_pseudowords_2_self_corrected = models.BooleanField("SC")
  repetition_pseudowords_2_repeated = models.BooleanField("R")
  repetition_pseudowords_3 = models.IntegerField("3. mibe", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_pseudowords_3_response = models.CharField("Response", max_length=128, blank=True)
  repetition_pseudowords_3_delayed = models.BooleanField("D")
  repetition_pseudowords_3_self_corrected = models.BooleanField("SC")
  repetition_pseudowords_3_repeated = models.BooleanField("R")
  repetition_pseudowords_4 = models.IntegerField("4. pramble", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_pseudowords_4_response = models.CharField("Response", max_length=128, blank=True)
  repetition_pseudowords_4_delayed = models.BooleanField("D")
  repetition_pseudowords_4_self_corrected = models.BooleanField("SC")
  repetition_pseudowords_4_repeated = models.BooleanField("R")
  repetition_pseudowords_5 = models.IntegerField("5. reifedest", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_pseudowords_5_response = models.CharField("Response", max_length=128, blank=True)
  repetition_pseudowords_5_delayed = models.BooleanField("D")
  repetition_pseudowords_5_self_corrected = models.BooleanField("SC")
  repetition_pseudowords_5_repeated = models.BooleanField("R")
  repetition_pseudowords_6 = models.IntegerField("6. piteretion", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  repetition_pseudowords_6_response = models.CharField("Response", max_length=128, blank=True)
  repetition_pseudowords_6_delayed = models.BooleanField("D")
  repetition_pseudowords_6_self_corrected = models.BooleanField("SC")
  repetition_pseudowords_6_repeated = models.BooleanField("R")
  repetition_pseudowords_notes = models.TextField(max_length=1024, blank=True)

  reading_words_1 = models.IntegerField("1. well", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_1_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_1_delayed = models.BooleanField("D")
  reading_words_1_self_corrected = models.BooleanField("SC")
  reading_words_2 = models.IntegerField("2. once", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_2_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_2_delayed = models.BooleanField("D")
  reading_words_2_self_corrected = models.BooleanField("SC")
  reading_words_3 = models.IntegerField("3. black", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_3_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_3_delayed = models.BooleanField("D")
  reading_words_3_self_corrected = models.BooleanField("SC")
  reading_words_4 = models.IntegerField("4. come", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_4_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_4_delayed = models.BooleanField("D")
  reading_words_4_self_corrected = models.BooleanField("SC")
  reading_words_5 = models.IntegerField("5. coil", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_5_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_5_delayed = models.BooleanField("D")
  reading_words_5_self_corrected = models.BooleanField("SC")
  reading_words_6 = models.IntegerField("6. sew", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_6_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_6_delayed = models.BooleanField("D")
  reading_words_6_self_corrected = models.BooleanField("SC")
  reading_words_7 = models.IntegerField("7. plaid", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_7_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_7_delayed = models.BooleanField("D")
  reading_words_7_self_corrected = models.BooleanField("SC")
  reading_words_8 = models.IntegerField("8. glide", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_8_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_8_delayed = models.BooleanField("D")
  reading_words_8_self_corrected = models.BooleanField("SC")
  reading_words_9 = models.IntegerField("9. cough", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_9_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_9_delayed = models.BooleanField("D")
  reading_words_9_self_corrected = models.BooleanField("SC")
  reading_words_10 = models.IntegerField("10. pint", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_10_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_10_delayed = models.BooleanField("D")
  reading_words_10_self_corrected = models.BooleanField("SC")
  reading_words_11 = models.IntegerField("11. octopus", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_11_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_11_delayed = models.BooleanField("D")
  reading_words_11_self_corrected = models.BooleanField("SC")
  reading_words_12 = models.IntegerField("12. temperature", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_12_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_12_delayed = models.BooleanField("D")
  reading_words_12_self_corrected = models.BooleanField("SC")
  reading_words_13 = models.IntegerField("13. unforgettable", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_13_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_13_delayed = models.BooleanField("D")
  reading_words_13_self_corrected = models.BooleanField("SC")
  reading_words_14 = models.IntegerField("14. indoctrination", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_14_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_14_delayed = models.BooleanField("D")
  reading_words_14_self_corrected = models.BooleanField("SC")
  reading_words_15 = models.IntegerField("15. and", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_15_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_15_delayed = models.BooleanField("D")
  reading_words_15_self_corrected = models.BooleanField("SC")
  reading_words_16 = models.IntegerField("16. of", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_16_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_16_delayed = models.BooleanField("D")
  reading_words_16_self_corrected = models.BooleanField("SC")
  reading_words_17 = models.IntegerField("17. the", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_17_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_17_delayed = models.BooleanField("D")
  reading_words_17_self_corrected = models.BooleanField("SC")
  reading_words_18 = models.IntegerField("18. for", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_words_18_response = models.CharField("Response", max_length=128, blank=True)
  reading_words_18_delayed = models.BooleanField("D")
  reading_words_18_self_corrected = models.BooleanField("SC")
  reading_words_notes = models.TextField(max_length=1024, blank=True)

  reading_sentences_1 = models.DecimalField("1. Please pick up the phone. (/5)", validators=[MinValueValidator(-1), MaxValueValidator(5)], null=True, blank=True, max_digits=3, decimal_places=1)
  reading_sentences_1_response = models.CharField("Response", max_length=1024, blank=True)
  reading_sentences_1_delayed = models.BooleanField("D")
  reading_sentences_1_self_corrected = models.BooleanField("SC")
  reading_sentences_2 = models.DecimalField("2. We thought that the show started at six o'clock. (/9)", validators=[MinValueValidator(-1), MaxValueValidator(9)], null=True, blank=True, max_digits=3, decimal_places=1)
  reading_sentences_2_response = models.CharField("Response", max_length=1024, blank=True)
  reading_sentences_2_delayed = models.BooleanField("D")
  reading_sentences_2_self_corrected = models.BooleanField("SC")
  reading_sentences_notes = models.TextField(max_length=1024, blank=True)

  reading_pseudowords_1 = models.IntegerField("1. deak", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_pseudowords_1_response = models.CharField("Response", max_length=128, blank=True)
  reading_pseudowords_1_delayed = models.BooleanField("D")
  reading_pseudowords_1_self_corrected = models.BooleanField("SC")
  reading_pseudowords_2 = models.IntegerField("2. fove", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_pseudowords_2_response = models.CharField("Response", max_length=128, blank=True)
  reading_pseudowords_2_delayed = models.BooleanField("D")
  reading_pseudowords_2_self_corrected = models.BooleanField("SC")
  reading_pseudowords_3 = models.IntegerField("3. gamp", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_pseudowords_3_response = models.CharField("Response", max_length=128, blank=True)
  reading_pseudowords_3_delayed = models.BooleanField("D")
  reading_pseudowords_3_self_corrected = models.BooleanField("SC")
  reading_pseudowords_4 = models.IntegerField("4. pook", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  reading_pseudowords_4_response = models.CharField("Response", max_length=128, blank=True)
  reading_pseudowords_4_delayed = models.BooleanField("D")
  reading_pseudowords_4_self_corrected = models.BooleanField("SC")
  reading_pseudowords_notes = models.TextField(max_length=1024, blank=True)

  semantic_knowledge_1 = models.IntegerField("1. lock", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  semantic_knowledge_2 = models.IntegerField("2. glasses", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  semantic_knowledge_3 = models.IntegerField("3. ironing board", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  semantic_knowledge_4 = models.IntegerField("4. carrot", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  semantic_knowledge_5 = models.IntegerField("5. owl", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  semantic_knowledge_6 = models.IntegerField("6. igloo", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  semantic_knowledge_notes = models.TextField(max_length=1024, blank=True)

  apraxia_1 = models.IntegerField("1. sniff", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  apraxia_2 = models.IntegerField("2. blow out a match", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  apraxia_3 = models.IntegerField("3. use a comb", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  apraxia_4 = models.IntegerField("4. use a toothbrush", validators=[MinValueValidator(-1), MaxValueValidator(2)], null=True, blank=True)
  apraxia_notes = models.TextField(max_length=1024, blank=True)

  digits_forward = models.IntegerField("Digit span forward", validators=[MinValueValidator(-1), MaxValueValidator(7)], null=True, blank=True)
  digits_backward = models.IntegerField("Digit span backward", validators=[MinValueValidator(-1), MaxValueValidator(7)], null=True, blank=True)
  digits_notes = models.TextField(max_length=1024, blank=True)

  line_bisection_1 = models.IntegerField("Line 1", validators=[MinValueValidator(-3), MaxValueValidator(3)], null=True, blank=True)
  line_bisection_2 = models.IntegerField("Line 2", validators=[MinValueValidator(-3), MaxValueValidator(3)], null=True, blank=True)
  line_bisection_3 = models.IntegerField("Line 3", validators=[MinValueValidator(-3), MaxValueValidator(3)], null=True, blank=True)
  line_bisection_notes = models.TextField(max_length=1024, blank=True)

  class Meta:
    db_table = 'LangEval'

  def __unicode__(self):
    return u'%s %s' % (self.date_acquired, self.data_type)

