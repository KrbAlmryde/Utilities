from django.contrib import admin
from django import forms
from neuroxy.models import *

class Textarea30x2(forms.Textarea):
  def __init__(self, *args, **kwargs):
    attrs = kwargs.setdefault('attrs', {})
    attrs.setdefault('cols', 30)
    attrs.setdefault('rows', 2)
    super(Textarea30x2, self).__init__(*args, **kwargs)

class Textarea30x1(forms.Textarea):
  def __init__(self, *args, **kwargs):
    attrs = kwargs.setdefault('attrs', {})
    attrs.setdefault('cols', 30)
    attrs.setdefault('rows', 1)
    super(Textarea30x1, self).__init__(*args, **kwargs)

class Textarea60x4(forms.Textarea):
  def __init__(self, *args, **kwargs):
    attrs = kwargs.setdefault('attrs', {})
    attrs.setdefault('cols', 60)
    attrs.setdefault('rows', 4)
    super(Textarea60x4, self).__init__(*args, **kwargs)

class Textarea60x2(forms.Textarea):
  def __init__(self, *args, **kwargs):
    attrs = kwargs.setdefault('attrs', {})
    attrs.setdefault('cols', 60)
    attrs.setdefault('rows', 2)
    super(Textarea60x2, self).__init__(*args, **kwargs)

class TextInput8(forms.TextInput):
  def __init__(self, *args, **kwargs):
    attrs = kwargs.setdefault('attrs', {})
    attrs.setdefault('size', 8)
    super(TextInput8, self).__init__(*args, **kwargs)

class TextInput16(forms.TextInput):
  def __init__(self, *args, **kwargs):
    attrs = kwargs.setdefault('attrs', {})
    attrs.setdefault('size', 16)
    super(TextInput16, self).__init__(*args, **kwargs)

class TextInput32(forms.TextInput):
  def __init__(self, *args, **kwargs):
    attrs = kwargs.setdefault('attrs', {})
    attrs.setdefault('size', 32)
    super(TextInput32, self).__init__(*args, **kwargs)

class MyInline(admin.TabularInline):
  extra = 0
  show_edit_link = True
  formfield_overrides = {
    models.CharField: {'widget': TextInput16},
    models.DecimalField: {'widget': TextInput8},
    models.TextField: {'widget': Textarea30x2},
    models.AutoField: {'widget': TextInput8},
  }

# obsolete
class DiagnosisInline(MyInline):
  model = Diagnosis
  formfield_overrides = {
    models.TextField: {'widget': TextInput32},
  }

class AddressInline(MyInline):
  model = Address
  formfield_overrides = {
    models.CharField: {'widget': TextInput16},
    models.DecimalField: {'widget': TextInput8},
    models.TextField: {'widget': TextInput32},
    models.AutoField: {'widget': TextInput8},
  }

class ConsentInline(MyInline):
  model = Consent

class DataInline(MyInline):
  model = Data
  show_edit_link = False
  can_delete = False
  fields = ('date_acquired', 'data_type')
  readonly_fields = ('date_acquired', 'data_type')

class NoteInline(MyInline):
  model = Note
  fields = ('date_acquired', 'time_acquired', 'data_type', 'status', 'acquired_by', 'acquired_by_2', 'location', 'project', 'participant_pay', 'notes')
  formfield_overrides = {
    models.TextField: {'widget': Textarea60x4},
  }

class ScanningSessionInline(MyInline):
  model = ScanningSession
  fields = ('pid', 'date_acquired', 'time_acquired', 'data_type', 'status', 'acquired_by', 'acquired_by_2', 'location', 'project', 'participant_pay', 'notes', 'scanner', 'scanning_cost', 'anatomical')
  raw_id_fields = ('anatomical',)

class LangEvalInline(MyInline):
  model = LangEval
  fields = ('date_acquired', 'time_acquired', 'data_type', 'status', 'acquired_by', 'acquired_by_2', 'location', 'project', 'participant_pay', 'notes')

class ParticipantAdmin(admin.ModelAdmin):
  model = Participant
#  list_display = ('first_name', 'get_photo_html')
  fieldsets = [
    (None, {'fields': [
      ('pid', 'first_name', 'middle_name', 'last_name'),
      ('date_of_birth', 'date_of_death', 'sex', 'handedness'),
      ('ssn', 'mrn', 'intake_date', 'project'),
      ('cohort', 'onset_date', 'onset_time'),
      ('notes', 'photo')
    ]}),
    ('Demographics', {'fields': [
      ('education', 'occupation', 'spouse_occupation', 'hispanic_or_latino', 'race'),
    ],'classes': ['collapse']}),
    ('Language history', {'fields': [
      ('primary_language', 'first_language', 'other_languages', 'where_grew_up'),
      ('spelling_ability', 'reading_ability', 'dyslexia_history', 'speech_language_history')
    ], 'classes': ['collapse']}),
    ('History', {'fields': [
      ('special_education_history', 'handedness_in_family', 'glasses', 'uncorrected_vision_problems'),
      ('hearing_loss', 'hearing_aid_left', 'hearing_aid_right'),
      'medications',
      ('head_injury', 'stroke', 'aphasia', 'brain_surgery', 'communication_disorder'),
      ('memory', 'depression', 'psychiatric', 'alcohol_abuse', 'substance_abuse'),
      ('dementia', 'parkinsons', 'epilepsy_seizure', 'other_neurological', 'other_major_illness'),
      ('general_health', 'psychoactive_meds'),
      'history_notes'
    ], 'classes': ['collapse']})
  ]
  formfield_overrides = {
    models.TextField: {'widget': Textarea60x2},
  }
  inlines = [AddressInline, ConsentInline, NoteInline, ScanningSessionInline, LangEvalInline]
  list_per_page = 500
  
#  list_display = ('pid', 'given_names', 'last_name', 'date_of_birth', 'sex', 'handedness', 'cohort', 'project')
#  list_display_links = ('pid', 'given_names', 'last_name')
  list_filter = ('project', 'cohort')


class ScanInline(MyInline):
  model = Scan

class ScanInlineStacked(admin.StackedInline):
  model = Scan
  extra = 0
  fieldsets = [
    (None, {'fields': [
      ('scan_type', 'acq_order', 'image_fname', 'status', 'quality'),
      ('fmri_study', 'run', 'n_vols', 'n_discard', 'paradigm', 'version'),
      ('behav_raw', 'behav_proc', 'segment', 'exclude_vols', 'manual_coreg', 'notes'),
    ]}),
  ]
  formfield_overrides = {
    models.TextField: {'widget': Textarea30x2}
  }

class ScanningSessionAdmin(admin.ModelAdmin):
  model = ScanningSession
  fieldsets = [
    (None, {'fields': [
      ('pid', 'date_acquired', 'time_acquired', 'data_type', 'status'),
      ('acquired_by', 'acquired_by_2', 'location', 'project', 'participant_pay'),
      ('notes', 'scanner', 'scanning_cost', 'anatomical')
    ]}),
  ]
  formfield_overrides = {
    models.TextField: {'widget': Textarea60x2}
  }
  raw_id_fields = ('anatomical',)
  inlines = [ScanInline]
  readonly_fields = ('pid',)

class LangEvalAdmin(admin.ModelAdmin):
  model = LangEval
  fieldsets = [
    (None, {'fields': [
      ('pid', 'date_acquired', 'time_acquired', 'data_type', 'status'),
      ('acquired_by', 'acquired_by_2', 'location', 'project', 'participant_pay'),
      'notes'
    ]}),
    ('1. Conversation', {'fields': [
      ('conversation', 'conversation_response'),
      'conversation_notes'
    ]}),
    ('2. Automatic speech', {'fields': [
      ('automatic_speech_1', 'automatic_speech_1_response'),
      ('automatic_speech_2', 'automatic_speech_2_response'),
      ('automatic_speech_3', 'automatic_speech_3_response'),
      'automatic_speech_notes'
    ]}),
    ('3. Oral agility', {'fields': [
      'oral_agility_1',
      'oral_agility_2',
      'oral_agility_notes'
    ]}),
    ('4. Articulatory agility', {'fields': [
      ('articulatory_agility_1', 'articulatory_agility_1_response'),
      ('articulatory_agility_2', 'articulatory_agility_2_response'),
      ('articulatory_agility_3', 'articulatory_agility_3_response'),
      ('articulatory_agility_4', 'articulatory_agility_4_response'),
      ('articulatory_agility_5', 'articulatory_agility_5_response'),
      ('articulatory_agility_6', 'articulatory_agility_6_response'),
      ('articulatory_agility_7', 'articulatory_agility_7_response'),
      ('articulatory_agility_8', 'articulatory_agility_8_response'),
      ('articulatory_agility_aos', 'articulatory_agility_dysarthria'),
      'articulatory_agility_notes'
    ]}),
    ('5. Connected speech', {'fields': [
      ('connected_speech_1', 'connected_speech_1_response'),
      ('connected_speech_2', 'connected_speech_2_response'),
      ('connected_speech_rate', 'connected_speech_mlu', 'connected_speech_phonology', 'connected_speech_morphosyntax', 'connected_speech_word_finding', 'connected_speech_relevance'),
      'connected_speech_notes'
    ]}),
    ('6. Picture naming', {'fields': [
      ('picture_naming_1', 'picture_naming_1_response', 'picture_naming_1_delayed', 'picture_naming_1_self_corrected'),
      ('picture_naming_2', 'picture_naming_2_response', 'picture_naming_2_delayed', 'picture_naming_2_self_corrected'),
      ('picture_naming_3', 'picture_naming_3_response', 'picture_naming_3_delayed', 'picture_naming_3_self_corrected'),
      ('picture_naming_4', 'picture_naming_4_response', 'picture_naming_4_delayed', 'picture_naming_4_self_corrected'),
      ('picture_naming_5', 'picture_naming_5_response', 'picture_naming_5_delayed', 'picture_naming_5_self_corrected'),
      ('picture_naming_6', 'picture_naming_6_response', 'picture_naming_6_delayed', 'picture_naming_6_self_corrected'),
      ('picture_naming_7', 'picture_naming_7_response', 'picture_naming_7_delayed', 'picture_naming_7_self_corrected'),
      ('picture_naming_8', 'picture_naming_8_response', 'picture_naming_8_delayed', 'picture_naming_8_self_corrected'),
      ('picture_naming_9', 'picture_naming_9_response', 'picture_naming_9_delayed', 'picture_naming_9_self_corrected'),
      ('picture_naming_10', 'picture_naming_10_response', 'picture_naming_10_delayed', 'picture_naming_10_self_corrected'),
      ('picture_naming_11', 'picture_naming_11_response', 'picture_naming_11_delayed', 'picture_naming_11_self_corrected'),
      ('picture_naming_12', 'picture_naming_12_response', 'picture_naming_12_delayed', 'picture_naming_12_self_corrected'),
      'picture_naming_notes'
    ]}),
    ('7. Picture naming (written)', {'fields': [
      ('picture_naming_written_1', 'picture_naming_written_1_response', 'picture_naming_written_1_delayed', 'picture_naming_written_1_self_corrected'),
      ('picture_naming_written_2', 'picture_naming_written_2_response', 'picture_naming_written_2_delayed', 'picture_naming_written_2_self_corrected'),
      ('picture_naming_written_3', 'picture_naming_written_3_response', 'picture_naming_written_3_delayed', 'picture_naming_written_3_self_corrected'),
      ('picture_naming_written_4', 'picture_naming_written_4_response', 'picture_naming_written_4_delayed', 'picture_naming_written_4_self_corrected'),
      'picture_naming_written_notes'
    ]}),
    ('8. Single word comprehension', {'fields': [
      ('single_word_comprehension_1', 'single_word_comprehension_1_response', 'single_word_comprehension_1_delayed', 'single_word_comprehension_1_self_corrected', 'single_word_comprehension_1_repeated'),
      ('single_word_comprehension_2', 'single_word_comprehension_2_response', 'single_word_comprehension_2_delayed', 'single_word_comprehension_2_self_corrected', 'single_word_comprehension_2_repeated'),
      ('single_word_comprehension_3', 'single_word_comprehension_3_response', 'single_word_comprehension_3_delayed', 'single_word_comprehension_3_self_corrected', 'single_word_comprehension_3_repeated'),
      ('single_word_comprehension_4', 'single_word_comprehension_4_response', 'single_word_comprehension_4_delayed', 'single_word_comprehension_4_self_corrected', 'single_word_comprehension_4_repeated'),
      ('single_word_comprehension_5', 'single_word_comprehension_5_response', 'single_word_comprehension_5_delayed', 'single_word_comprehension_5_self_corrected', 'single_word_comprehension_5_repeated'),
      ('single_word_comprehension_6', 'single_word_comprehension_6_response', 'single_word_comprehension_6_delayed', 'single_word_comprehension_6_self_corrected', 'single_word_comprehension_6_repeated'),
      ('single_word_comprehension_7', 'single_word_comprehension_7_response', 'single_word_comprehension_7_delayed', 'single_word_comprehension_7_self_corrected', 'single_word_comprehension_7_repeated'),
      ('single_word_comprehension_8', 'single_word_comprehension_8_response', 'single_word_comprehension_8_delayed', 'single_word_comprehension_8_self_corrected', 'single_word_comprehension_8_repeated'),
      ('single_word_comprehension_9', 'single_word_comprehension_9_response', 'single_word_comprehension_9_delayed', 'single_word_comprehension_9_self_corrected', 'single_word_comprehension_9_repeated'),
      ('single_word_comprehension_10', 'single_word_comprehension_10_response', 'single_word_comprehension_10_delayed', 'single_word_comprehension_10_self_corrected', 'single_word_comprehension_10_repeated'),
      ('single_word_comprehension_11', 'single_word_comprehension_11_response', 'single_word_comprehension_11_delayed', 'single_word_comprehension_11_self_corrected', 'single_word_comprehension_11_repeated'),
      ('single_word_comprehension_12', 'single_word_comprehension_12_response', 'single_word_comprehension_12_delayed', 'single_word_comprehension_12_self_corrected', 'single_word_comprehension_12_repeated'),
      ('single_word_comprehension_13', 'single_word_comprehension_13_response', 'single_word_comprehension_13_delayed', 'single_word_comprehension_13_self_corrected', 'single_word_comprehension_13_repeated'),
      ('single_word_comprehension_14', 'single_word_comprehension_14_response', 'single_word_comprehension_14_delayed', 'single_word_comprehension_14_self_corrected', 'single_word_comprehension_14_repeated'),
      ('single_word_comprehension_15', 'single_word_comprehension_15_response', 'single_word_comprehension_15_delayed', 'single_word_comprehension_15_self_corrected', 'single_word_comprehension_15_repeated'),
      ('single_word_comprehension_16', 'single_word_comprehension_16_response', 'single_word_comprehension_16_delayed', 'single_word_comprehension_16_self_corrected', 'single_word_comprehension_16_repeated'),
      'single_word_comprehension_notes'
    ]}),
    ('9. Single word comprehension (reading)', {'fields': [
      ('single_word_comprehension_reading_1', 'single_word_comprehension_reading_1_response', 'single_word_comprehension_reading_1_delayed', 'single_word_comprehension_reading_1_self_corrected', 'single_word_comprehension_reading_1_repeated'),
      ('single_word_comprehension_reading_2', 'single_word_comprehension_reading_2_response', 'single_word_comprehension_reading_2_delayed', 'single_word_comprehension_reading_2_self_corrected', 'single_word_comprehension_reading_2_repeated'),
      ('single_word_comprehension_reading_3', 'single_word_comprehension_reading_3_response', 'single_word_comprehension_reading_3_delayed', 'single_word_comprehension_reading_3_self_corrected', 'single_word_comprehension_reading_3_repeated'),
      ('single_word_comprehension_reading_4', 'single_word_comprehension_reading_4_response', 'single_word_comprehension_reading_4_delayed', 'single_word_comprehension_reading_4_self_corrected', 'single_word_comprehension_reading_4_repeated'),
      'single_word_comprehension_reading_notes'
    ]}),
    ('10. Sentence comprehension', {'fields': [
      ('sentence_comprehension_1', 'sentence_comprehension_1_response', 'sentence_comprehension_1_delayed', 'sentence_comprehension_1_self_corrected', 'sentence_comprehension_1_repeated'),
      ('sentence_comprehension_2', 'sentence_comprehension_2_response', 'sentence_comprehension_2_delayed', 'sentence_comprehension_2_self_corrected', 'sentence_comprehension_2_repeated'),
      ('sentence_comprehension_3', 'sentence_comprehension_3_response', 'sentence_comprehension_3_delayed', 'sentence_comprehension_3_self_corrected', 'sentence_comprehension_3_repeated'),
      ('sentence_comprehension_4', 'sentence_comprehension_4_response', 'sentence_comprehension_4_delayed', 'sentence_comprehension_4_self_corrected', 'sentence_comprehension_4_repeated'),
      ('sentence_comprehension_5', 'sentence_comprehension_5_response', 'sentence_comprehension_5_delayed', 'sentence_comprehension_5_self_corrected', 'sentence_comprehension_5_repeated'),
      ('sentence_comprehension_6', 'sentence_comprehension_6_response', 'sentence_comprehension_6_delayed', 'sentence_comprehension_6_self_corrected', 'sentence_comprehension_6_repeated'),
      ('sentence_comprehension_7', 'sentence_comprehension_7_response', 'sentence_comprehension_7_delayed', 'sentence_comprehension_7_self_corrected', 'sentence_comprehension_7_repeated'),
      ('sentence_comprehension_8', 'sentence_comprehension_8_response', 'sentence_comprehension_8_delayed', 'sentence_comprehension_8_self_corrected', 'sentence_comprehension_8_repeated'),
      ('sentence_comprehension_9', 'sentence_comprehension_9_response', 'sentence_comprehension_9_delayed', 'sentence_comprehension_9_self_corrected', 'sentence_comprehension_9_repeated'),
      ('sentence_comprehension_10', 'sentence_comprehension_10_response', 'sentence_comprehension_10_delayed', 'sentence_comprehension_10_self_corrected', 'sentence_comprehension_10_repeated'),
      ('sentence_comprehension_11', 'sentence_comprehension_11_response', 'sentence_comprehension_11_delayed', 'sentence_comprehension_11_self_corrected', 'sentence_comprehension_11_repeated'),
      ('sentence_comprehension_12', 'sentence_comprehension_12_response', 'sentence_comprehension_12_delayed', 'sentence_comprehension_12_self_corrected', 'sentence_comprehension_12_repeated'),
      'sentence_comprehension_notes'
    ], 'classes': ['wide']}),
    ('11. Sentence comprehension (reading)', {'fields': [
      ('sentence_comprehension_reading_1', 'sentence_comprehension_reading_1_response', 'sentence_comprehension_reading_1_delayed', 'sentence_comprehension_reading_1_self_corrected', 'sentence_comprehension_reading_1_repeated'),
      ('sentence_comprehension_reading_2', 'sentence_comprehension_reading_2_response', 'sentence_comprehension_reading_2_delayed', 'sentence_comprehension_reading_2_self_corrected', 'sentence_comprehension_reading_2_repeated'),
      ('sentence_comprehension_reading_3', 'sentence_comprehension_reading_3_response', 'sentence_comprehension_reading_3_delayed', 'sentence_comprehension_reading_3_self_corrected', 'sentence_comprehension_reading_3_repeated'),
      ('sentence_comprehension_reading_4', 'sentence_comprehension_reading_4_response', 'sentence_comprehension_reading_4_delayed', 'sentence_comprehension_reading_4_self_corrected', 'sentence_comprehension_reading_4_repeated'),
      'sentence_comprehension_reading_notes'
    ], 'classes': ['wide']}),
    ('12. Repetition of words', {'fields': [
      ('repetition_words_1', 'repetition_words_1_response', 'repetition_words_1_delayed', 'repetition_words_1_self_corrected', 'repetition_words_1_repeated'),
      ('repetition_words_2', 'repetition_words_2_response', 'repetition_words_2_delayed', 'repetition_words_2_self_corrected', 'repetition_words_2_repeated'),
      ('repetition_words_3', 'repetition_words_3_response', 'repetition_words_3_delayed', 'repetition_words_3_self_corrected', 'repetition_words_3_repeated'),
      ('repetition_words_4', 'repetition_words_4_response', 'repetition_words_4_delayed', 'repetition_words_4_self_corrected', 'repetition_words_4_repeated'),
      ('repetition_words_5', 'repetition_words_5_response', 'repetition_words_5_delayed', 'repetition_words_5_self_corrected', 'repetition_words_5_repeated'),
      ('repetition_words_6', 'repetition_words_6_response', 'repetition_words_6_delayed', 'repetition_words_6_self_corrected', 'repetition_words_6_repeated'),
      ('repetition_words_7', 'repetition_words_7_response', 'repetition_words_7_delayed', 'repetition_words_7_self_corrected', 'repetition_words_7_repeated'),
      ('repetition_words_8', 'repetition_words_8_response', 'repetition_words_8_delayed', 'repetition_words_8_self_corrected', 'repetition_words_8_repeated'),
      ('repetition_words_9', 'repetition_words_9_response', 'repetition_words_9_delayed', 'repetition_words_9_self_corrected', 'repetition_words_9_repeated'),
      ('repetition_words_10', 'repetition_words_10_response', 'repetition_words_10_delayed', 'repetition_words_10_self_corrected', 'repetition_words_10_repeated'),
      ('repetition_words_11', 'repetition_words_11_response', 'repetition_words_11_delayed', 'repetition_words_11_self_corrected', 'repetition_words_11_repeated'),
      'repetition_words_notes'
    ]}),
    ('13. Repetition of sentences', {'fields': [
      ('repetition_sentences_1', 'repetition_sentences_1_response', 'repetition_sentences_1_delayed', 'repetition_sentences_1_self_corrected', 'repetition_sentences_1_repeated'),
      ('repetition_sentences_2', 'repetition_sentences_2_response', 'repetition_sentences_2_delayed', 'repetition_sentences_2_self_corrected', 'repetition_sentences_2_repeated'),
      ('repetition_sentences_3', 'repetition_sentences_3_response', 'repetition_sentences_3_delayed', 'repetition_sentences_3_self_corrected', 'repetition_sentences_3_repeated'),
      ('repetition_sentences_4', 'repetition_sentences_4_response', 'repetition_sentences_4_delayed', 'repetition_sentences_4_self_corrected', 'repetition_sentences_4_repeated'),
      ('repetition_sentences_5', 'repetition_sentences_5_response', 'repetition_sentences_5_delayed', 'repetition_sentences_5_self_corrected', 'repetition_sentences_5_repeated'),
      ('repetition_sentences_6', 'repetition_sentences_6_response', 'repetition_sentences_6_delayed', 'repetition_sentences_6_self_corrected', 'repetition_sentences_6_repeated'),
      ('repetition_sentences_7', 'repetition_sentences_7_response', 'repetition_sentences_7_delayed', 'repetition_sentences_7_self_corrected', 'repetition_sentences_7_repeated'),
      'repetition_sentences_notes'
    ], 'classes': ['wide']}),
    ('14. Repetition of pseudowords', {'fields': [
      ('repetition_pseudowords_1', 'repetition_pseudowords_1_response', 'repetition_pseudowords_1_delayed', 'repetition_pseudowords_1_self_corrected', 'repetition_pseudowords_1_repeated'),
      ('repetition_pseudowords_2', 'repetition_pseudowords_2_response', 'repetition_pseudowords_2_delayed', 'repetition_pseudowords_2_self_corrected', 'repetition_pseudowords_2_repeated'),
      ('repetition_pseudowords_3', 'repetition_pseudowords_3_response', 'repetition_pseudowords_3_delayed', 'repetition_pseudowords_3_self_corrected', 'repetition_pseudowords_3_repeated'),
      ('repetition_pseudowords_4', 'repetition_pseudowords_4_response', 'repetition_pseudowords_4_delayed', 'repetition_pseudowords_4_self_corrected', 'repetition_pseudowords_4_repeated'),
      ('repetition_pseudowords_5', 'repetition_pseudowords_5_response', 'repetition_pseudowords_5_delayed', 'repetition_pseudowords_5_self_corrected', 'repetition_pseudowords_5_repeated'),
      ('repetition_pseudowords_6', 'repetition_pseudowords_6_response', 'repetition_pseudowords_6_delayed', 'repetition_pseudowords_6_self_corrected', 'repetition_pseudowords_6_repeated'),
      'repetition_pseudowords_notes'
    ]}),
    ('15. Reading of words', {'fields': [
      ('reading_words_1', 'reading_words_1_response', 'reading_words_1_delayed', 'reading_words_1_self_corrected'),
      ('reading_words_2', 'reading_words_2_response', 'reading_words_2_delayed', 'reading_words_2_self_corrected'),
      ('reading_words_3', 'reading_words_3_response', 'reading_words_3_delayed', 'reading_words_3_self_corrected'),
      ('reading_words_4', 'reading_words_4_response', 'reading_words_4_delayed', 'reading_words_4_self_corrected'),
      ('reading_words_5', 'reading_words_5_response', 'reading_words_5_delayed', 'reading_words_5_self_corrected'),
      ('reading_words_6', 'reading_words_6_response', 'reading_words_6_delayed', 'reading_words_6_self_corrected'),
      ('reading_words_7', 'reading_words_7_response', 'reading_words_7_delayed', 'reading_words_7_self_corrected'),
      ('reading_words_8', 'reading_words_8_response', 'reading_words_8_delayed', 'reading_words_8_self_corrected'),
      ('reading_words_9', 'reading_words_9_response', 'reading_words_9_delayed', 'reading_words_9_self_corrected'),
      ('reading_words_10', 'reading_words_10_response', 'reading_words_10_delayed', 'reading_words_10_self_corrected'),
      ('reading_words_11', 'reading_words_11_response', 'reading_words_11_delayed', 'reading_words_11_self_corrected'),
      ('reading_words_12', 'reading_words_12_response', 'reading_words_12_delayed', 'reading_words_12_self_corrected'),
      ('reading_words_13', 'reading_words_13_response', 'reading_words_13_delayed', 'reading_words_13_self_corrected'),
      ('reading_words_14', 'reading_words_14_response', 'reading_words_14_delayed', 'reading_words_14_self_corrected'),
      ('reading_words_15', 'reading_words_15_response', 'reading_words_15_delayed', 'reading_words_15_self_corrected'),
      ('reading_words_16', 'reading_words_16_response', 'reading_words_16_delayed', 'reading_words_16_self_corrected'),
      ('reading_words_17', 'reading_words_17_response', 'reading_words_17_delayed', 'reading_words_17_self_corrected'),
      ('reading_words_18', 'reading_words_18_response', 'reading_words_18_delayed', 'reading_words_18_self_corrected'),
      'reading_words_notes'
    ]}),
    ('16. Reading of sentences', {'fields': [
      ('reading_sentences_1', 'reading_sentences_1_response', 'reading_sentences_1_delayed', 'reading_sentences_1_self_corrected'),
      ('reading_sentences_2', 'reading_sentences_2_response', 'reading_sentences_2_delayed', 'reading_sentences_2_self_corrected'),
      'reading_sentences_notes'
    ], 'classes': ['wide']}),
    ('17. Reading of pseudowords', {'fields': [
      ('reading_pseudowords_1', 'reading_pseudowords_1_response', 'reading_pseudowords_1_delayed', 'reading_pseudowords_1_self_corrected'),
      ('reading_pseudowords_2', 'reading_pseudowords_2_response', 'reading_pseudowords_2_delayed', 'reading_pseudowords_2_self_corrected'),
      ('reading_pseudowords_3', 'reading_pseudowords_3_response', 'reading_pseudowords_3_delayed', 'reading_pseudowords_3_self_corrected'),
      ('reading_pseudowords_4', 'reading_pseudowords_4_response', 'reading_pseudowords_4_delayed', 'reading_pseudowords_4_self_corrected'),
      'reading_pseudowords_notes'
    ]}),
    ('18. Semantic knowledge', {'fields': [
      ('semantic_knowledge_1', 'semantic_knowledge_2', 'semantic_knowledge_3', 'semantic_knowledge_4', 'semantic_knowledge_5', 'semantic_knowledge_6'),
      'semantic_knowledge_notes'
    ]}),
    ('19. Apraxia', {'fields': [
      ('apraxia_1', 'apraxia_2', 'apraxia_3', 'apraxia_4'),
      'apraxia_notes'
    ]}),
    ('20. Digit span', {'fields': [
      ('digits_forward', 'digits_backward'),
      'digits_notes'
    ]}),
    ('21. Line bisection', {'fields': [
      ('line_bisection_1', 'line_bisection_2', 'line_bisection_3'),
      'line_bisection_notes'
    ]}),
  ]
  formfield_overrides = {
    models.TextField: {'widget': Textarea60x2}
  }
  readonly_fields = ('pid',)

admin.site.register(Researcher)
admin.site.register(Location)
admin.site.register(Project)
admin.site.register(Cohort)
admin.site.register(Race)
admin.site.register(Participant, ParticipantAdmin)
# admin.site.register(Syndrome)
# admin.site.register(Diagnosis)
admin.site.register(Address)
admin.site.register(ConsentFormDate)
admin.site.register(Consent)
admin.site.register(DataType)
admin.site.register(DataStatus)
admin.site.register(Data)
admin.site.register(Note)
admin.site.register(Scanner)
admin.site.register(ScanningSession, ScanningSessionAdmin)
admin.site.register(ScanType)
admin.site.register(FmriStudy)
admin.site.register(Paradigm)
admin.site.register(ScanStatus)
admin.site.register(ScanQuality)
admin.site.register(Scan)
admin.site.register(LangEval, LangEvalAdmin)

