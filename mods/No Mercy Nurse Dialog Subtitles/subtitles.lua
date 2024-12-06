local text_original = LocalizationManager.text
local testAllStrings = false

function LocalizationManager:text(string_id, ...)
return string_id == "doc_nmh_run_03_sub" and "This patient was brought in with a toxin in their bloodstream. Their heart rate is abnormal."
or string_id == "doc_nmh_run_04_sub" and "There are traces of toxins in this patient's bloodstream, and they are not responding to any treatments. This might be what we call the Green Flu."
or string_id == "doc_nmh_run_02_sub" and "This patient's heart rate is stable, and they will be out of the ICU soon."
or string_id == "doc_nmh_run_06_sub" and "This patient has a stable blood pressure and will be out of the hospital in a couple of days."
or string_id == "doc_nmh_run_05_sub" and "This man's blood pressure is outside the usual range. However, they will recover soon."
or string_id == "doc_nmh_a_sub" and "Dr. Schneider: Welcome! Follow me and we'll start the route."
or string_id == "doc_nmh_f_sub" and "Let's check the blood pressure as well."
or string_id == "doc_nmh_h_sub" and "If you need me, I'll be over there."
or string_id == "doc_nmh_i_sub" and "That's all I can tell you about the patients, doctor."
or string_id == "doc_nmh_run_01_sub" and "This man was brought in with symptoms of an illness. Their hearthrate is abnormal."
or string_id == "doc_nmh_b_sub" and "First, let's look at isolation B."
or string_id == "doc_nmh_run_07_sub" and "This patient has a very unusual blood pressure. He will need to stay in the ICU for an undefined period of time until more research is conducted."
or string_id == "doc_nmh_run_08_sub" and "This patient has a current blood pressure which is well different from the usual levels. His heartrate is also unstable."

or testAllStrings == true and string_id
or text_original(self, string_id, ...)
end