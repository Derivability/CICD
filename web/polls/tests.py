from django.test import TestCase
from polls.models import Choice
from django.utils import timezone
from polls.models import Question

# models test
class PollsTest(TestCase):

    def create_question(self, text="only a test"):
        return Question.objects.create(question_text=text, pub_date=timezone.now())
    def create_choice(self, text, question):
        return Choice.objects.create(choice_text=text, question=question)

    def test_question_creation(self):
        q = self.create_question()
        self.assertTrue(isinstance(q, Question))
        self.assertEqual("only a test1", q.question_text)

    def test_choice_creation(self):
        q = self.create_question()
        a = self.create_choice("just test answer",q)

        self.assertTrue(isinstance(a, Choice))
        self.assertEqual("just test answer", a.choice_text)