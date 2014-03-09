import ceylon.test { test, assertTrue, assertFalse, assertEquals }
import ceylon.collection { PriorityQueue, ArrayList }

shared test void testEmptyPriorityQueue() {
    value queue = newQueue();
    assertTrue(queue.empty);
}

shared test void testEmptyPriorityQueueAccept() {
    value queue = newQueue();
    assertEquals(queue.accept(), null);
}

shared void testEmptyPriorityQueueFront() {
    value queue = newQueue();
    assertEquals(queue.front, null);
}

shared test void testPriorityQueueWithOneElement() {
    value queue = newQueue();
    queue.offer(7);
    assertFalse(queue.empty);
    assertEquals(queue.front, 7);
    assertFalse(queue.empty);
    assertEquals(queue.accept(), 7);
    assertTrue(queue.empty);
    assertEquals(queue.front, null);
    assertEquals(queue.accept(), null);
}

{Integer+} orderedValues = { -5, 1, 4, 5, 7, 8, 9 };
{Integer+} elementsIterable = { 7, 4, 5, 8, 1, 9, -5 };

shared test void testPriorityQueueWithSeveralElementsIterable() {
    value queue = newQueue(elementsIterable);
    checkEmptyQueue(queue, orderedValues);
}

shared test void testPriorityQueueWithSeveralElementsCollection() {
    value queue = newQueue(ArrayList { *elementsIterable });
    checkEmptyQueue(queue, orderedValues);
}

shared test void testPriorityQueueWithSeveralElementsSequence() {
    value queue = newQueue(elementsIterable.sequence);
    checkEmptyQueue(queue, orderedValues);
}

PriorityQueue<Integer> newQueue({Integer*} elements = {}) => PriorityQueue {
    compare = (Integer first, Integer second) => first.compare(second);
    elements = elements;
};

void checkEmptyQueue(PriorityQueue<Integer> queue, {Integer*} orderedValues) {
    for (item in orderedValues) {
        assertFalse(queue.empty);
        assertEquals(queue.front, item);
        assert(exists last = queue.last);
        assertFalse(queue.empty);
        assertEquals(queue.accept(), item);
    }
    assertTrue(queue.empty);
    assertEquals(queue.front, null);
    assertEquals(queue.last, null);
}
