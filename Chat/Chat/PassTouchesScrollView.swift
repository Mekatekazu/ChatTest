import UIKit

protocol PassTouchesScrollViewDelegate {
    func touchScrollBegan()
    func touchScrollMoved()
}


class PassTouchesScrollView: UIScrollView {
    
    var delegatePass : PassTouchesScrollViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // Notify it's delegate about touched
        self.delegatePass?.touchScrollBegan()
        
        if self.dragging == true {
            self.nextResponder()?.touchesBegan(touches, withEvent: event)
        } else {
            super.touchesBegan(touches, withEvent: event)
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)  {
        
        // Notify it's delegate about touched
        self.delegatePass?.touchScrollMoved()
        
        if self.dragging == true {
            self.nextResponder()?.touchesMoved(touches, withEvent: event)
        } else {            
            super.touchesMoved(touches, withEvent: event)
        }
    }   
}