---
layout: post
title: Auto Assign Point Estimate
disqus: y
share: y
categories: [Management]
tags: [Java, Google Api]
---

Background
----------
Every sprint we need to do the point estimates, it is part of Agile development process, then use tools such as Jira or confluence etc. to help management the sprint. It is very important to estimate before actually do it, however, it require doing proper assignment. Image that if the your team is big, with hundred of stories in the list, it will be painful to average the point and assign to people.

Smart Assign
----------
The purpose of program is to make things easier, for this case, we can easily use greedy algorithm to write a code which help assignment. Below is a example of Java version smart assignment:

Full code:
~~~Java
class Story{
	String id;
	int points;
	Story(String id, int points){
		this.id = id;
		this.points = points;
	}
}
class Person{
	String name;
	int points;
	Person(String name, int points){
		this.name = name;
		this.points = points;
	}
}
public class PointEsitmateAssign {

	private HashMap<Person, List<Story>> pointEstimate(List<Story> stories, List<Person> persons){
		LinkedHashMap<Person, List<Story>> res = new LinkedHashMap<Person, List<Story>>();
		if(persons==null||persons.isEmpty()||stories==null||stories.isEmpty()) return res;
		
		Collections.sort(stories, ((a,b)->b.points-a.points));
		PriorityQueue<Person> pq = new PriorityQueue<Person>((a,b)->b.points-a.points);
		for(Person p: persons){
			pq.offer(p);
			res.put(p, new ArrayList<Story>());
		}
		for(Story story: stories){
			List<Person> randomPersonList = new ArrayList<Person>();
			int expectPoint = story.points;
			//can use reservoir sampling to improve here
			
			int peekPoint = pq.peek().points;
			while(!pq.isEmpty()&&pq.peek().points==peekPoint){
				randomPersonList.add(pq.poll());
			}
			if(randomPersonList.isEmpty()){
				Person p = pq.poll();
				p.points = p.points - expectPoint;
				res.get(p).add(story);
				pq.offer(p);
			} else {
				Collections.shuffle(randomPersonList);
				Person choosenOne = randomPersonList.remove(0);
				choosenOne.points = choosenOne.points - expectPoint;
//				System.out.println(randomPersonList.size());
				res.get(choosenOne).add(story);
				pq.offer(choosenOne);
				for(Person p : randomPersonList) pq.offer(p);
			}
		}
		return res;
	}
	
	private void debug(HashMap<Person, List<Story>> res){
		System.out.print("==================Assignment===================== \n");
		if(res!=null){
			for(Map.Entry<Person, List<Story>> item: res.entrySet()){
				System.out.print(item.getKey().name +" assigned: ");
				int sum = 0;
				for(int i=0;i<item.getValue().size();i++){
					System.out.print("("+item.getValue().get(i).id+","+item.getValue().get(i).points+"),");
					sum += item.getValue().get(i).points;
				}
				System.out.print(" Sum: "+ sum +"\n");
			}
		}
	}
	
	public static void main(String[] args) {
		PointEsitmateAssign pea = new PointEsitmateAssign();
		List<Story> stories1 = new ArrayList<Story>(Arrays.asList(
				new Story("1", 2), new Story("2", 2), new Story("3", 3),
				new Story("4", 1), new Story("5", 4), new Story("6", 6),
				new Story("7", 5), new Story("8", 3), new Story("9", 1)
		));
		List<Person> persons1 = new ArrayList<Person>(Arrays.asList(
				new Person("A", 13), new Person("B", 6), new Person("C", 8)
		));
		HashMap<Person, List<Story>> res1 = pea.pointEstimate(stories1, persons1);
		pea.debug(res1);
		
		List<Story> stories2 = new ArrayList<Story>(Arrays.asList(
				new Story("1", 3), new Story("2", 3), new Story("3", 3),new Story("4", 3)
		));
		List<Person> persons2 = new ArrayList<Person>(Arrays.asList(
				new Person("A", 4), new Person("B", 4), new Person("C", 4)
		));
		HashMap<Person, List<Story>> res2 = pea.pointEstimate(stories2, persons2);
		pea.debug(res2);
	}

}
~~~

Google Spreadsheet Script
-----------
Since many of us use Google spreadsheet to do the document, here is an example for Google spreadsheet version:
[Point Estimate Auto Script](https://docs.google.com/spreadsheets/d/1czBh9U0iMkhPl7ifh1_lgYj1Vr43JxAnhW9Wn3pepcA/edit#gid=0)

~~~
function autoAssignment() {
  var sheet = SpreadsheetApp.getActiveSheet(); 
  var persons = sheet.getRange("G3:G11");
  
  for( var i = 0; i < persons.getValues().length; i++) {
    var targetCell = sheet.getRange("C"+(i+3));
    
    //sort the stories by highest points
    var storyRange = sheet.getRange("A3:C11");
    storyRange.sort({column: 2, ascending: false});
    
    //sort the persons by highest left points
    var personRange = sheet.getRange("G3:J10");
    personRange.sort({column: 10, ascending: false});
    
    var sourceValue = sheet.getRange("G3").getValue();
    targetCell.setValue(sourceValue);
  }
}
~~~

Reference
---------
[Extending Google Sheets](https://developers.google.com/apps-script/guides/sheets)
