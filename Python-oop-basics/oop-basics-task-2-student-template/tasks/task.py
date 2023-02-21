# Complete the following code according to the task in README.md.
# Don't change names of classes. Create names for the variables
# exactly the same as in the task.
class SchoolMember:
    def __init__(self,name: str, age: int,):
        #self.person = person
        self.name = name
        self.age = age
        print('Name:"{}" Age:"{}"'.format(self.name, self.age), end=" ")
    def show(self):
        '''Tell my details.'''
        print('Name:"{}" Age:"{}"'.format(self.name, self.age), end=" ")

class Teacher(SchoolMember):

    def __init__(self, name: str, age: int, salary: int):
        SchoolMember.__init__(self, name, age)
        self.salary = salary
        print('(Initialized Teacher: {})'.format(self.name))

    def show(self):
        SchoolMember.show(self)
        print('Salary: "{:d}"'.format(self.salary))

class Student(SchoolMember):
    def __init__(self, name: str, age: int, grades):
        SchoolMember.__init__(self, name, age)
        self.grades = grades
        print('(Initialized Student: {})'.format(self.name))

    def show(self):
        SchoolMember.show(self)
        print('Grades: "{:d}"'.format(self.grades))

t = Teacher( 'James Smith', 40, 1000)
s = Student('Swaroop', 25, {'Grades': 5, 'PE': 3})

# prints a blank line
print()

members = [t, s]
for member in members:
    # Works for both Teachers and Students
    member.show()

