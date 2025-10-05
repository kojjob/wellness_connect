import { Application } from "@hotwired/stimulus"
import CounterAnimationController from "../../../app/javascript/controllers/counter_animation_controller"

describe("CounterAnimationController", () => {
  let application
  let element

  beforeEach(() => {
    application = Application.start()
    application.register("counter-animation", CounterAnimationController)
    
    element = document.createElement("div")
    element.setAttribute("data-controller", "counter-animation")
    element.setAttribute("data-counter-animation-end-value", "5000")
    element.setAttribute("data-counter-animation-duration-value", "1000")
    
    const numberElement = document.createElement("span")
    numberElement.setAttribute("data-counter-animation-target", "number")
    numberElement.textContent = "0"
    element.appendChild(numberElement)
    
    document.body.appendChild(element)
  })

  afterEach(() => {
    document.body.removeChild(element)
    application.stop()
  })

  it("animates number from 0 to end value", (done) => {
    const numberElement = element.querySelector("[data-counter-animation-target='number']")
    
    // Trigger intersection observer
    const controller = application.getControllerForElementAndIdentifier(element, "counter-animation")
    controller.animate()
    
    setTimeout(() => {
      const value = parseInt(numberElement.textContent.replace(/,/g, ""))
      expect(value).toBeGreaterThan(0)
      done()
    }, 500)
  })

  it("formats numbers with commas", (done) => {
    const numberElement = element.querySelector("[data-counter-animation-target='number']")
    
    const controller = application.getControllerForElementAndIdentifier(element, "counter-animation")
    controller.animate()
    
    setTimeout(() => {
      expect(numberElement.textContent).toMatch(/,/)
      done()
    }, 1100)
  })

  it("adds suffix if provided", (done) => {
    element.setAttribute("data-counter-animation-suffix-value", "+")
    
    const numberElement = element.querySelector("[data-counter-animation-target='number']")
    const controller = application.getControllerForElementAndIdentifier(element, "counter-animation")
    controller.animate()
    
    setTimeout(() => {
      expect(numberElement.textContent).toContain("+")
      done()
    }, 1100)
  })

  it("respects decimals value", (done) => {
    element.setAttribute("data-counter-animation-end-value", "4.9")
    element.setAttribute("data-counter-animation-decimals-value", "1")
    
    const numberElement = element.querySelector("[data-counter-animation-target='number']")
    const controller = application.getControllerForElementAndIdentifier(element, "counter-animation")
    controller.animate()
    
    setTimeout(() => {
      expect(numberElement.textContent).toMatch(/\d\.\d/)
      done()
    }, 1100)
  })

  it("only animates once", (done) => {
    const controller = application.getControllerForElementAndIdentifier(element, "counter-animation")
    
    controller.animate()
    controller.animate() // Try to animate again
    
    setTimeout(() => {
      expect(controller.hasAnimated).toBe(true)
      done()
    }, 100)
  })
})

