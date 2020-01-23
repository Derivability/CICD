from django.test import TestCase
from polls.models import Choice
from django.utils import timezone
from polls.models import Question

# models test
class PollsTest(TestCase):
    text_question = "only a test question"
    text_choice = "just a test answer"

    def create_question(self):
        return Question.objects.create(question_text=PollsTest.text_question, pub_date=timezone.now())
    def create_choice(self, question):
        return Choice.objects.create(choice_text=PollsTest.text_choice, question=question)

    def test_question_creation(self):
        q = self.create_question()
        self.assertTrue(isinstance(q, Question))
        self.assertEqual(PollsTest.text_question, q.question_text)

    def test_choice_creation(self):
        q = self.create_question()
        a = self.create_choice(q)

        self.assertTrue(isinstance(a, Choice))
        self.assertEqual(PollsTest.text_choice, a.choice_text)